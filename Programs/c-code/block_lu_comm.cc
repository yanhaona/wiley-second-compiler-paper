\begin{interimC}{luf-comm}{A part of the thread run function of block-LU factorization interim C++ code illustring use of an array communicator.}
if (threadState->isValidPpu(Space_A)) {
	// invoking user computation
	int stage19Executed = generatepivotcolumn_stage_18(spaceALpu, 
					arrayMetadata, 
					taskGlobals, 
					threadLocals, 
					partition, 
					threadState->threadLog);
	p_columnStage19No1 += stage19Executed;
}
// communicating updates
if (threadState->isValidPpu(Space_A)) {
	Communicator *communicator 
			= threadState->getCommunicator("p_columnStage19No1");
	if (communicator != NULL) {
		if (p_columnStage19No1 > 0) {
			communicator->send(REQUESTING_COMMUNICATION, commCounter5);
		} else communicator->send(PASSIVE_REPORTING, commCounter5);
	}
	p_columnStage19No1 = 0;
}
// waiting on data reception
if (threadState->isValidPpu(Space_B)) {
	Communicator *communicator 
			= threadState->getCommunicator("p_columnStage19No1");
	if (communicator != NULL) {
		communicator->receive(REQUESTING_COMMUNICATION, commCounter5);
	}
}
commCounter5++;
	{ // scope entrance for iterating LPUs of Space B
	int spaceBLpuId = INVALID_ID;
	int spaceBIteration = 0;
	SpaceB_LPU *spaceBLpu = NULL;
	LPU *lpu = NULL;
	while((lpu = threadState->getNextLpu(Space_B, 
			Space_A, spaceBLpuId)) != NULL) {
		spaceBLpu = (SpaceB_LPU*) lpu;
		if (threadState->isValidPpu(Space_B)) {
			// invoking user computation
			int stage21Executed = updateucolsblock_stage_20(spaceBLpu, 
					arrayMetadata, 
					taskGlobals, 
					threadLocals, 
					partition, 
					threadState->threadLog);
			uStage21No4 += stage21Executed;
		}
\end{interimC}