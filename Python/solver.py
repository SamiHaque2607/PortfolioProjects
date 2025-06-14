from typing import List

# This function solves a Sudoku board using the classic backtracking method.
# It modifies the board in-place and returns True if a solution is found.
def solve_sudoku(board: List[List[str]]) -> bool:

    # This checks if it's okay to place a specific number in a cell.
    # It makes sure the number isn't already in the same row, column, or 3x3 box.
    def is_valid(row, col, num):
        for i in range(9):
            # Check if the number already exists in this column or row
            if board[i][col] == num or board[row][i] == num:
                return False
            # This checks the 3x3 box the cell belongs to
            box_row = 3 * (row // 3) + i // 3
            box_col = 3 * (col // 3) + i % 3
            if board[box_row][box_col] == num:
                return False
        return True

    # This is the recursive function that fills the board step by step
    def fill(row, col):
        if row == 9:
            return True  # We've filled all 9 rows — puzzle is done
        if col == 9:
            return fill(row + 1, 0)  # Move to the next row
        if board[row][col] != '.':
            return fill(row, col + 1)  # Skip cells that are already filled

        # Try putting numbers 1–9 in this cell
        for num in map(str, range(1, 10)):
            if is_valid(row, col, num):
                board[row][col] = num  # Try this number
                if fill(row, col + 1):  # Move to the next cell
                    return True
                board[row][col] = '.'  # If it didn’t work, reset and backtrack

        return False  # If no number fits, we return False to trigger backtracking

    return fill(0, 0)  # Start solving from the top-left cell (0, 0)
