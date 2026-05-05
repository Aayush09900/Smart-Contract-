// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Taskmanager {

    enum Status{Todo, Inprogress, completed}

    struct task{
        string name;
        Status status;
    }

    mapping(string => task) public status;

    function Create_task(string memory _name) public {
        status[_name] = task(_name, Status.Todo);
    }
    function update_taskstatus(string memory _name, uint _status) public {
        status[_name].status = Status(_status);
    }
}