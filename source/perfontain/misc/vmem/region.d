module perfontain.misc.vmem.region;


struct AllocRegion
{
	uint start;
	uint value;

	const ubyte[] data;
	void delegate() onMove;
}
