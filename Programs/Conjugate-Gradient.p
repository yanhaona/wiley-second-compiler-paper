\begin{codeExampleListing}{highp5-cg}{The program coordinator module for a multi-task implementation of the conjugate gradient program.}
Program (args) {
  // creating environment objects for component tasks
  vaEnv1 = new TaskEnvironment(name: "Vector Add")
  vaEnv2 = new TaskEnvironment(name: "Vector Add")
  dpEnv = new TaskEnvironment(name: "Vector Dot Prod")
  mvmEnv1 = new TaskEnvironment(name: "CSR Matrix Vector Mult")
  mvmEnv2 = new TaskEnvironment(name: "CSR Matrix Vector Mult")
        
  // make the argument sparse matrix stored in compressed row 
  // format from files to be read during first-time execution 
  // of the matrix-vector multiply task
  bind_input(mvmEnv1, "columns", args.arg_matrix_cols)
  bind_input(mvmEnv1, "rows", args.arg_matrix_rows)
  bind_input(mvmEnv1, "values", args.arg_matrix_values)

  // bind the prediction (x_0) and known vector (b) to the tasks' 
  // environment that use them initially   
  bind_input(vaEnv1, "u", args.known_vector)
  bind_input(mvmEnv1, "v", args.prediction_vector)
  
  // run the conjugate gradient logic
  iteration = 0
  maxIterations = args.maxIterations
  do {
     // calculate A * x_i
     execute(task: "CSR Matrix Vector Mult"; 
          environment: mvmEnv1; partition: args.r)              
     // determine the current residual error r_i = b - A * x_i
     vaEnv1.alpha = 1
     vaEnv1.v = mvmEnv1.w
     vaEnv1.beta = -1
     execute(task: "Vector Add"; 
        environment: vaEnv1; partition: args.b)     
     // determine  r_i.r_i as the residual norm
     dpEnv.u = dpEnv.v = vaEnv1.w
     execute(task: "Vector Dot Prod"; 
           environment: dpEnv; partition: args.b)
     norm = dpEnv.product
     // in the first iteration setup duplicate environmental 
     // references for the sparse matrix components
     if (iteration == 0) {
        mvmEnv2.columns = mvmEnv1.columns
        mvmEnv2.rows = mvmEnv1.rows
        mvmEnv2.values = mvmEnv1.values
     }
     // determine A * r_i
     mvmEnv2.v = vaEnv1.w
     execute(task: "CSR Matrix Vector Mult"; 
          environment: mvmEnv2; partition: args.r)
     // determine dot product of r_i to A * r_i
     dpEnv.v = mvmEnv2.w
     execute(task: "Vector Dot Prod"; 
          environment: dpEnv; partition: args.b)
     // update the step size to (r_i.r_i) / (r_i.(A * r_i))
     alpha_i = norm / dpEnv.product
     // calculate the next estimate x_i = x_i + alpha_i * r_i
     vaEnv2.u = mvmEnv1.v
     vaEnv2.alpha = 1
     vaEnv2.v = vaEnv1.w
     vaEnv2.beta = alpha_i
     execute(task: "Vector Add"; 
        environment: vaEnv2; partition: args.b)
     // prepare x_i for the next iteration
     mvmEnv1.v = vaEnv2.w
     iteration = iteration + 1
   } while iteration < maxIterations and norm > args.precision
   
   // store the final solution vector in an output file
   bind_output(vaEnv2, "w", args.solution_vector)
}
\end{codeExampleListing}
