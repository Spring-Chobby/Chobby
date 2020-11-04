#include "../role.as"


namespace Builder {

//AIFloat3 lastPos;

IUnitTask@ MakeTask(CCircuitUnit@ unit)
{
//	aiDelPoint(lastPos);
//	lastPos = unit.GetPos(ai.GetLastFrame());
//	aiAddPoint(lastPos, "task");
//	return aiBuilderMgr.DefaultMakeTask(unit);

	IUnitTask@ task = aiBuilderMgr.DefaultMakeTask(unit);
//	if ((task !is null) && (task.GetType() == 5) && (task.GetBuildType() == 5)) {
//		aiDelPoint(task.GetBuildPos());
//		aiAddPoint(task.GetBuildPos(), "def");
//	}
	return task;
}

}  // namespace Builder
