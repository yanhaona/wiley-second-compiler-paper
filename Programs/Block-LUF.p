\begin{codeExampleListing}{highp5-luf}{The parallel computation flow and partitioning section for data distribution of HighP5 program solving block-LU factorization.}
Computation:
   Space A {
     Space B { prepareLU(a, u, l) }
     Repeat for r in a.dimension1.range step block_size {
        calculateRowRange(a, r, row_range, block_size)
        Repeat for k in row_range {
           Space B {
              Where k in u.local.dimension1.range { 
                   selectPivot(Space A: pivot, u, k) 
              }
           }
           storePivot(p, k, pivot)
           Space B {
              If k != pivot { interchangeRows(pivot, k, u, l) }
              Where k in l.local.dimension1.range  { 
                  updateL(u, l, k, l_row) 
              }
              updateURowsBlock(u, l_row, k, row_range)
              collectLColParts(l_column, l, k, row_range)
           }
           generatePivotColumn(p_column, l_column, row_range, k)
           Space B {
              updateUColsBlock(u, p_column, k, row_range)
           }
        }
        Space B {
           copyUpdatedUBlock(u_block, row_range, u)
           Where r in l.local.dimension1.range { 
              copyUpdatedLBlock(l_block, row_range, l) 
           }
           Space C {
              Repeat foreach sub-partition {
                 saxpy(u, u_block, l_block, row_range)
              }
           }
        }
      }
   }
Partition(b, p):
    Space A <un-partitioned> { 
        a, p, l_column, l_row, p_column, l_block, u_block 
    }
    Space B <1d> divides Space A partitions {
        a<dim2>, u<dim1>, u_block<dim1>: block_stride(b)
        l<dim1>, l_column: block_stride(b)
        l_row, p_column, l_block: replicated 
    }
    Space C <2d> divides Space B partitions {
        u: block_size(b, b)
        u_block: block_size(b), replicated
        l_block: replicated, block_size(b)
        Sub-partition <1d> <unordered> {
            u_block<dim2>, l_block<dim1>: block_size(p)
        }
    } 
\end{codeExampleListing}
