// This is the same Sudoku solver I wrote in Python, but now in C++
// The logic is exactly the same (recursive backtracking), just written in C++
// The point here is to show how much faster it runs compared to Python
// I use this to solve 1 million puzzles and time how long it takes

#include <iostream>
#include <fstream>
#include <vector>
#include <chrono>
using namespace std;

// This function takes a long 81-character puzzle string and
// breaks it into a 9x9 grid, converting '0's into empty cells ('.')
vector<vector<char>> parsePuzzle(const string& line) {
    vector<vector<char>> board(9, vector<char>(9, '.'));
    for (int i = 0; i < 81; ++i) {
        char ch = line[i];
        board[i / 9][i % 9] = (ch == '0') ? '.' : ch;
    }
    return board;
}

// Checks if placing a number is allowed in this cell
// Basically just follows Sudoku rules: no repeats in row, column, or box
bool isValid(vector<vector<char>>& board, int row, int col, char num) {
    for (int i = 0; i < 9; ++i) {
        if (board[row][i] == num || board[i][col] == num)
            return false;

        // This checks the 3x3 box the cell is in
        int boxRow = 3 * (row / 3) + i / 3;
        int boxCol = 3 * (col / 3) + i % 3;
        if (board[boxRow][boxCol] == num)
            return false;
    }
    return true;
}

// This is the main backtracking function that actually solves the board
bool solveSudoku(vector<vector<char>>& board, int row = 0, int col = 0) {
    if (row == 9) return true;  // done
    if (col == 9) return solveSudoku(board, row + 1, 0);  // move to next row
    if (board[row][col] != '.') return solveSudoku(board, row, col + 1);  // skip filled cells

    // Try all numbers 1–9 and see what works
    for (char num = '1'; num <= '9'; ++num) {
        if (isValid(board, row, col, num)) {
            board[row][col] = num;  // try this number
            if (solveSudoku(board, row, col + 1))  // solve rest of board
                return true;
            board[row][col] = '.';  // backtrack if it fails
        }
    }
    return false;  // nothing fits, backtrack
}

int main() {
    ifstream file("sudoku.csv");
    string header, line;
    getline(file, header);  // skip the header row ("quizzes,solutions")

    vector<string> puzzles;
    
    // Read the first 1 million puzzles from the file
    while (getline(file, line)) {
        string puzzle = line.substr(0, 81);  // only take the puzzle string
        if (puzzle.size() == 81)
            puzzles.push_back(puzzle);
        if (puzzles.size() == 1000000) break;
    }

    // Start the timer
    auto start = chrono::high_resolution_clock::now();

    // Solve each puzzle one by one
    for (const auto& puzzle : puzzles) {
        auto board = parsePuzzle(puzzle);
        solveSudoku(board);
    }

    // Stop the timer
    auto end = chrono::high_resolution_clock::now();
    chrono::duration<double> duration = end - start;

    // Print the result to the terminal
    cout << "Solved " << puzzles.size() << " puzzles in "
         << duration.count() << " seconds." << endl;

    // Write the solve time to a file so Python can read it later
    ofstream out("cpp_time.txt");
    out << duration.count() << endl;
    out.close();

    return 0;
}
