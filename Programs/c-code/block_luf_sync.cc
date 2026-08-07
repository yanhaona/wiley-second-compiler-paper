\begin{interimC}{luf-sync}{A part of the thread run function of block-LU factorization interim C++ code illustring how synchronization is implemented.}	
	while((lpu = threadState->getNextLpu(Space_B, 
					Space_A, spaceBLpuId)) != NULL) {
		spaceBLpu = (SpaceB_LPU*) lpu;
		if (threadState->isValidPpu(Space_B)) {
			// invoking user computation
			int stage21Executed = updateucolsblock_stage_20(spaceBLpu,
							arrayMetadata,
							taskGlobals,
							threadLocals, partition, threadState->threadLog);
			uStage21No4 += stage21Executed;
		}
		spaceBLpuId = spaceBLpu->id;
		spaceBIteration++;
	}
	threadState->removeIterationBound(Space_A);
} // scope exit for iterating LPUs of Space B
repeatIteration++;
} // scope exit for repeat loop

// resolving synchronization dependencies
if (uStage21No4 > 0 && threadState->isValidPpu(Space_B)) {
	threadSync->uStage21No4DSync->signal(repeatIteration);
	uStage21No4 = 0;
} else if (threadState->isValidPpu(Space_C_Sub)) {
	threadSync->uStage21No4DSync->wait(repeatIteration);
}

{ // scope entrance for iterating LPUs of Space B
int spaceBLpuId = INVALID_ID;
int spaceBIteration = 0;
SpaceB_LPU *spaceBLpu = NULL;
LPU *lpu = NULL;
while((lpu = threadState->getNextLpu(Space_B, 
				Space_A, spaceBLpuId)) != NULL) {
	spaceBLpu = (SpaceB_LPU*) lpu;
	// barriers to ensure all readers have read the  last update
	if (threadState->isValidPpu(Space_C_Sub)) {
		threadSync->u_blockStage23No1ReverseSync->wait();
	}
	if (threadState->isValidPpu(Space_B)) {
		// invoking user computation
		int stage23Executed = copyupdatedublock_stage_22(spaceBLpu,
						arrayMetadata,
						taskGlobals,
						threadLocals, partition, threadState->threadLog);
\end{interimC}
