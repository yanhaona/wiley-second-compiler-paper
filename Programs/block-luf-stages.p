\begin{codeExampleListing}{highp5-luf-stages}{Define and a part of Stages sections of the block-LU factorization task.}
Define:
    a, u, l: 2d Array of Real double-precision
    p: 1d Array of Integer
    l_row, l_column, p_column: 1d Array of Real double-precision
    u_block, l_block: 2d Array of Real double-precision
    pivot: Integer Reduction
    k, r, block_size: Integer
    row_range: Range
Stages:
    selectPivot(pivot, u, k) {
        do { reduce(pivot, "max_entry", u[k][j]) 
        } for j in u and j >= k
    }
    storePivot(p, k, pivot) {
        p[k] = pivot
    }
    interchangeRows(pivot, k, u, l) {
        do {   pivot_entry = u[i][k]
               u[i][k] = u[i][pivot]
               u[i][pivot] = pivot_entry
        } for i in u and i >= k
        do {   pivot_entry = l[i][k]
               l[i][k] = l[i][pivot]
               l[i][pivot] = pivot_entry
        } for i in l and i < k
    }
    updateL(u, l, k, l_row) {
        do {   l[k][j] = u[k][j] / u[k][k]
               u[k][j] = 0
               l_row[j] = l[k][j]
        } for j in l and j > k
    }
    updateURowsBlock(u, l_row, k, row_range) {
        do {   u[i][j] = u[i][j] - l_row[j] * u[i][k] 
        } for i, j in u and i > k 
              and i <= row_range.max and j > k
    }
    collectLColParts(l_column, l, k, row_range) {
        do {   l_column[i] = l[i][k]
        } for i in l and i >= row_range.min and i < k
    }
    generatePivotColumn(p_column, l_column, row_range, k) {
         do { p_column[i] = l_column[i]
         } for i in l_column and i >= row_range.min and i < k
    }
    saxpy(u, u_block, l_block, row_range) {
        do {
            total = 0.000000
            do {  total = total + u_block[i][m] * l_block[m][j] 
            } for m in u_block
           u[i][j] = u[i][j] - total
        } for i, j in u 
              and i > row_range.max and j > row_range.max
    }
\end{codeExampleListing}
