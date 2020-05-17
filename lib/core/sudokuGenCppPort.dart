import 'dart:developer';
import 'dart:io';

import 'bidimensional_list.dart';
import 'dart:typed_data';
import 'dart:math';
import 'sudoku_state.dart';
class Ptr<T> {
  final int count;
  final List<T> _values;
  Ptr.allocate(int size) : count = size, _values = List<T>(size);
  Ptr(T value) : count = 1, _values = List<T>(1)..[0] = value;

  operator [](int i) => _values[i];
  operator []=(int i, T val) => _values[i] = val;
  T get val => _values[0];
  set val(T val) => _values[0] = val;
}

final int UNASSIGNED = 0;

// START: Helper functions for solving grid
bool FindUnassignedLocation(BidimensionalList<int> grid, Ptr<int> row, Ptr<int> col)
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

bool UsedInRow(BidimensionalList<int> grid, int row, int num)
{
    for (int col = 0; col < 9; col++)
    {
        if (grid[row][col] == num)
            return true;
    }

    return false;
}

bool UsedInCol(BidimensionalList<int> grid, int col, int num)
{
    for (int row = 0; row < 9; row++)
    {
        if (grid[row][col] == num)
            return true;
    }

    return false;
}

bool UsedInBox(BidimensionalList<int> grid, int boxStartRow, int boxStartCol, int num)
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

bool isSafe(BidimensionalList<int> grid, int row, int col, int num)
{
    return !UsedInRow(grid, row, num) && !UsedInCol(grid, col, num) && !UsedInBox(grid, row - row%3 , col - col%3, num);
}

class PortedSudoku {
  BidimensionalList<int> grid = BidimensionalList.view(Uint8List(9*9), 9);
  BidimensionalList<int> solnGrid = BidimensionalList.view(Uint8List(9*9), 9);
  List<int> guessNum = Uint8List(9);
  List<int> gridPos = Uint8List(9*9);
  int difficultyLevel;
  PortedSudoku._();

  factory PortedSudoku() {
    final ths = PortedSudoku._();
    // initialize difficulty level
    ths.difficultyLevel = 0;

    // Randomly shuffling the array of removing grid positions
    for(int i=0;i<81;i++)
    {
      ths.gridPos[i] = i;
    }

    ths.gridPos.shuffle();

    // Randomly shuffling the guessing number array
    for(int i=0;i<9;i++)
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
    for(int i=0;i<9;i++)
    {
      for(int j=0;j<9;j++)
      {
        solnGrid[i][j] = grid[i][j];
      }
    }
  }

  void printGrid()
  {
    for(int i=0;i<9;i++)
    {
      for(int j=0;j<9;j++)
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
  bool solveGrid()
  {
      Ptr<int> row = Ptr(0), col = Ptr(0);

      // If there is no unassigned location, we are done
      if (!FindUnassignedLocation(grid, row, col))
        return true; // success!
      
      // Consider digits 1 to 9
      for (int num = 0; num < 9; num++)
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

  void countSoln(Ptr<int> number)
  {
    Ptr<int> row = Ptr(0), col = Ptr(0);

    if(!FindUnassignedLocation(grid, row, col))
    {
      number.val = number.val+1;
      return ;
    }


    for(int i=0;i<9 && number.val<2;i++)
    {
        if( isSafe(grid, row.val, col.val, guessNum[i]) )
        {
          grid[row.val][col.val] = guessNum[i];
          countSoln(number);
        }

        grid[row.val][col.val] = UNASSIGNED;
    }

  }
  void genPuzzle()
  {
    for(int i=0;i<81;i++)
    {
      int x = (gridPos[i])~/9;
      int y = (gridPos[i])%9;
      int temp = grid[x][y];
      grid[x][y] = UNASSIGNED;

      // If now more than 1 solution , replace the removed cell back.
      Ptr<int> check=Ptr(0);
      countSoln(check);
      if(check.val!=1)
      {
        grid[x][y] = temp;
      }
    }
  }
  void calculateDifficulty()
  {
    int B = branchDifficultyScore();
    int emptyCells = 0;

    for(int i=0;i<9;i++)
    {
      for(int j=0;j<9;j++)
      {
    if(grid[i][j] == 0)
      emptyCells++;
      }
    } 

    difficultyLevel = B*100 + emptyCells;
  }
  int  branchDifficultyScore()
  {
    int emptyPositions = -1;
    BidimensionalList<int> tempGrid = BidimensionalList<int>.view(Uint8List(9*9), 9);
    int sum=0;

    for(int i=0;i<9;i++)
    {
      for(int j=0;j<9;j++)
      {
        tempGrid[i][j] = grid[i][j];
      }
    }

    while(emptyPositions!=0)
    {
      List<List<int>> empty = <List<int>>[]; 

      for(int i=0;i<81;i++)
      {
          if(tempGrid[i~/9][i%9] == 0)
          {
            List<int> temp = <int>[];
            temp.add(i);
          
            for(int num=1;num<=9;num++)
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

      int minIndex = 0;

      int check = empty.length;
      for(int i=0;i<check;i++)
      {
        if(empty[i].length < empty[minIndex].length)
      minIndex = i;
      }

      int branchFactor=empty[minIndex].length;
      int rowIndex = empty[minIndex][0]~/9;
      int colIndex = empty[minIndex][0]%9;

      tempGrid[rowIndex][colIndex] = solnGrid[rowIndex][colIndex];
      sum = sum + ((branchFactor-2) * (branchFactor-2)) ;

      emptyPositions = empty.length - 1;
    }

    return sum;

  }
}

int genRandNum(int maxLimit)
{
  return Random().nextInt(maxLimit); //TODO: check inclusive or exclusive
}

BidimensionalList<int> quickAndDartyGen({double mask_rate = 0.5})
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