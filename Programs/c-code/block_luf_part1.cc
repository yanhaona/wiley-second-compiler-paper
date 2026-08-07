\begin{interimC}{luf-thread-run-part}{A small portion of the thread run function for block-LUF showing how stage functions are invoked for LPUs in interim C++ code.}
{ // scope entrance for iterating LPUs of Space B
	int spaceBLpuId = INVALID_ID;
	int spaceBIteration = 0;
	SpaceB_LPU *spaceBLpu = NULL;
	LPU *lpu = NULL;
	while((lpu = threadState->getNextLpu(Space_B, 
					Space_A, spaceBLpuId)) != NULL) {
		spaceBLpu = (SpaceB_LPU*) lpu;
		{ // scope entrance for conditional subflow
			Dimension uPartDims[2];
			Dimension uStoreDims[2];
			uPartDims[0] = spaceBLpu->uPartDims[0].partition;
			uStoreDims[0] = spaceBLpu->uPartDims[0].storage;
			uPartDims[1] = spaceBLpu->uPartDims[1].partition;
			uStoreDims[1] = spaceBLpu->uPartDims[1].storage;
			if((xformIndex = threadLocals->k,
				partConfig = *(&spaceBLpu->uPartDims[0]),
					(xformIndex % (partition.b * partConfig.count)) 
						/ partition.b == partConfig.index)) {
				if (threadState->isValidPpu(Space_B)) {
					// invoking user computation
					int stage10Executed = selectpivot_stage_9(spaceBLpu, 
							arrayMetadata, 
							taskGlobals, 
							threadLocals, 
							reductionResultsMap, 
							partition, 
							threadState->threadLog);
				}
			} // end of condition checking block
		} // scope exit for conditional subflow
		spaceBLpuId = spaceBLpu->id;
		spaceBIteration++;
	}
	threadState->removeIterationBound(Space_A);
} // scope exit for iterating LPUs of Space B
\end{interimC}
