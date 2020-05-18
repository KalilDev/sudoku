import 'dart:developer';
import 'dart:io';

import 'bidimensional_list.dart';
import 'dart:typed_data';
import 'dart:math';
import 'nnbd_helper.dart';
import 'sudoku_state.dart';

typedef Grid = NonNull<BidimensionalList<NonNull<int>>>;
typedef IntPtr = NonNull<Ptr<NonNull<int>>>;

class Ptr<T> {
  final int count;
  final List<T> _values;
  Ptr.allocate(int size, T fill) : count = size, _values = List<T>.filled(size, fill);
  Ptr(T value) : count = 1, _values = List.filled(1, value);

  operator [](int i) => _values[i];
  operator []=(int i, T val) => _values[i] = val;
  T get val => _values[0];
  set val(T val) => _values[0] = val;
}

final int UNASSIGNED = 0;

// START: Helper functions for solving grid
Bool FindUnassignedLocation(Grid grid, IntPtr row, IntPtr col)
{
    for (row.val = 0; row.val < 9; row.val = row.val+1)
    {
        for (col.val = 0; col.val < 9; col.val = col.val+1)
        {
            if (grid[row.val][col.val] == UNASSIGNED)
                return true;
        }
    }

    return false;
}

Bool UsedInRow(Grid grid, Int row, Int num)
{
    for (int col = 0; col < 9; col++)
    {
        if (grid[row][col] == num)
            return true;
    }

    return false;
}

Bool UsedInCol(Grid grid, Int col, Int num)
{
    for (int row = 0; row < 9; row++)
    {
        if (grid[row][col] == num)
            return true;
    }

    return false;
}

Bool UsedInBox(Grid grid, Int boxStartRow, Int boxStartCol, Int num)
{
    for (int row = 0; row < 3; row++)
    {
        for (int col = 0; col < 3; col++)
        {
            if (grid[row+boxStartRow][col+boxStartCol] == num)
                return true;
        }
    }

    return false;
}

Bool isSafe(Grid grid, Int row, Int col, Int num)
{
    return !UsedInRow(grid, row, num) && !UsedInCol(grid, col, num) && !UsedInBox(grid, row - row%3 , col - col%3, num);
}

class PortedSudoku {
  Grid grid = BidimensionalList<Int>.view(Uint8List(9*9), 9);
  Grid solnGrid = BidimensionalList<Int>.view(Uint8List(9*9), 9);
  IntList guessNum = Uint8List(9);
  IntList gridPos = Uint8List(9*9);
  Int difficultyLevel = 0;
  PortedSudoku._();

  factory PortedSudoku() {
    final ths = PortedSudoku._();

    // Randomly shuffling the array of removing grid positions
    for(var i=0;i<81;i++)
    {
      ths.gridPos[i] = i;
    }

    ths.gridPos.shuffle();

    // Randomly shuffling the guessing number array
    for(var i=0;i<9;i++)
    {
      ths.guessNum[i]=i+1;
    }

    ths.guessNum.shuffle();
    return ths;
  }

  void createSeed()
  { 
    solveGrid();
    
    // Saving the solution grid
    for(var i=0;i<9;i++)
    {
      for(var j=0;j<9;j++)
      {
        solnGrid[i][j] = grid[i][j];
      }
    }
  }

  void printGrid()
  {
    for(var i=0;i<9;i++)
    {
      for(var j=0;j<9;j++)
      {
        if(grid[i][j] == 0)
          stdout.write(".");
        else
          stdout.write(grid[i][j]);
        stdout.write("|");
      }
      stdout.write('\n');
    }

    stdout.write("\nDifficulty of current sudoku(0 being easiest): $difficultyLevel");
    stdout.write('\n');
  }
  Bool solveGrid()
  {
      IntPtr row = Ptr(0), col = Ptr(0);

      // If there is no unassigned location, we are done
      if (!FindUnassignedLocation(grid, row, col))
        return true; // success!
      
      // Consider digits 1 to 9
      for (var num = 0; num < 9; num++)
      {
          // if looks promising
          if (isSafe(grid, row.val, col.val, guessNum[num]))
          {
              // make tentative assignment
              grid[row.val][col.val] = guessNum[num];

              // return, if success, yay!
              if (solveGrid())
                  return true;

              // failure, unmake & try again
              grid[row.val][col.val] = UNASSIGNED;
          }
      }

      return false; // this triggers backtracking

  }

  void countSoln(IntPtr number)
  {
    IntPtr row = Ptr(0), col = Ptr(0);

    if(!FindUnassignedLocation(grid, row, col))
    {
      number.val = number.val+1;
      return ;
    }


    for(var i=0;i<9 && number.val<2;i++)
    {
        if(isSafe(grid, row.val, col.val, guessNum[i]) )
        {
          grid[row.val][col.val] = guessNum[i];
          countSoln(number);
        }

        grid[row.val][col.val] = UNASSIGNED;
    }

  }
  void genPuzzle()
  {
    for(var i=0;i<81;i++)
    {
      Int x = (gridPos[i])~/9;
      Int y = (gridPos[i])%9;
      Int temp = grid[x][y];
      grid[x][y] = UNASSIGNED;

      // If now more than 1 solution , replace the removed cell back.
      IntPtr check = Ptr(0);
      countSoln(check);
      if(check.val!=1)
      {
        grid[x][y] = temp;
      }
    }
  }
  void calculateDifficulty()
  {
    Int B = branchDifficultyScore();
    Int emptyCells = 0;

    for(var i=0;i<9;i++)
    {
      for(var j=0;j<9;j++)
      {
    if(grid[i][j] == 0)
      emptyCells++;
      }
    } 

    difficultyLevel = B*100 + emptyCells;
  }
  Int branchDifficultyScore()
  {
    Int emptyPositions = -1;
    Grid tempGrid = BidimensionalList<Int>.view(Uint8List(9*9), 9);
    Int sum=0;

    for(Int i=0;i<9;i++)
    {
      for(Int j=0;j<9;j++)
      {
        tempGrid[i][j] = grid[i][j];
      }
    }

    while(emptyPositions!=0)
    {
      NonNull<List<IntList>> empty = <IntList>[]; 

      for(var i=0;i<81;i++)
      {
          if(tempGrid[i~/9][i%9] == 0)
          {
            IntList temp = <Int>[];
            temp.add(i);
          
            for(var num=1;num<=9;num++)
            {
              if(isSafe(tempGrid,i~/9,i%9,num))
              {
                temp.add(num);
              }
            }

            empty.add(temp);
          }
        
      }

      if(empty.length == 0)
      { 
        stdout.write('Hello: $sum\n');
        return sum;
      } 

      Int minIndex = 0;

      Int check = empty.length;
      for(var i=0;i<check;i++)
      {
        if(empty[i].length < empty[minIndex].length)
      minIndex = i;
      }

      Int branchFactor=empty[minIndex].length;
      Int rowIndex = empty[minIndex][0]~/9;
      Int colIndex = empty[minIndex][0]%9;

      tempGrid[rowIndex][colIndex] = solnGrid[rowIndex][colIndex];
      sum = sum + ((branchFactor-2) * (branchFactor-2)) ;

      emptyPositions = empty.length - 1;
    }

    return sum;

  }
}

Int genRandNum(Int maxLimit)
{
  return Random().nextInt(maxLimit); //TODO: check inclusive or exclusive
}

Grid quickAndDartyGen({NonNull<double> mask_rate = 0.5})
{
  mask_rate = 1 - mask_rate;
  // Creating an instance of Sudoku
  PortedSudoku puzzle = PortedSudoku();

  // Creating a seed for puzzle generation
  puzzle.createSeed();

  // Generating the puzzle
  puzzle.genPuzzle();

  // Calculating difficulty of puzzle
  //puzzle.calculateDifficulty();

  final count = puzzle.grid.whereInner((n) => n != UNASSIGNED).length;
  var toBeAdded = (81*mask_rate).round() - count;
  if (toBeAdded < 0) {
    return puzzle.grid;
  }
  while (toBeAdded > 0) {
    final x = Random().nextInt(9);
    final y = Random().nextInt(9);
    final onGrid = puzzle.grid[y][x];
    if (onGrid != UNASSIGNED) {
      continue;
    }
    print("sol: ${puzzle.solnGrid[y][x]}");
    puzzle.grid[y][x] = puzzle.solnGrid[y][x];
    toBeAdded--;
  }
  return puzzle.grid;
}

void main() {
  print(quickAndDartyGen());
}