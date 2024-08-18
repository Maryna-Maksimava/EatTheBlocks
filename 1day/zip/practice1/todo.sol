// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ToDoList {
    struct Task {
        uint256 taskId;
        string description;
        bool isCompleted;
    }

    mapping(uint256 => Task) private tasks;
    uint256[] private taskIds;
    uint256 private nextTaskId = 1;

    // Event to log when a task is added
    event TaskAdded(uint256 taskId, string description);

    // Event to log when a task is marked as completed
    event TaskCompleted(uint256 taskId);

    // Event to log when a task is removed
    event TaskRemoved(uint256 taskId);

    error TaskNotExists(uint256 givenTaskId);

    // Function to add a new task
    function addTask(string memory _description) external {
        tasks[nextTaskId] = Task({
            taskId: nextTaskId,
            description: _description,
            isCompleted: false
        });
        taskIds.push(nextTaskId);
        emit TaskAdded(nextTaskId, _description);
        nextTaskId++;
    }

    // Function to mark a task as completed
    function completeTask(uint256 _taskId) external {
        _ensureTaskExists(_taskId);
        tasks[_taskId].isCompleted = true;
        emit TaskCompleted(_taskId);
    }

    // Function to remove a task
    function removeTask(uint256 _taskId) external {
        _ensureTaskExists(_taskId);
        delete tasks[_taskId];

        // Remove task ID from taskIds array
        for (uint256 i = 0; i < taskIds.length; i++) {
            if (taskIds[i] == _taskId) {
                // if yes
                taskIds[i] = taskIds[taskIds.length - 1]; // then replace actual task with last task
                taskIds.pop(); // and remove last task
                break;
            }
        }

        emit TaskRemoved(_taskId);
    }

    // Function to get the list of task IDs
    function getTaskIds() external view returns (uint256[] memory) {
        return taskIds;
    }

    // Function to get a specific task by its ID
    function getTask(
        uint256 _taskId
    ) external view returns (string memory description, bool isCompleted) {
        _ensureTaskExists(_taskId);
        Task memory task = tasks[_taskId];
        return (task.description, task.isCompleted);
    }

    function _ensureTaskExists(uint256 _taskId) internal view {
        if (tasks[_taskId].taskId == 0) {
            revert TaskNotExists(_taskId);
        }
    }
}
