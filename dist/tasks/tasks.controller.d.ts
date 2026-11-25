import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
export declare class TasksController {
    private readonly tasksService;
    constructor(tasksService: TasksService);
    findAll(): import("./tasks.entity").Task[];
    findOne(id: number): import("./tasks.entity").Task;
    create(dto: CreateTaskDto): import("./tasks.entity").Task;
    update(id: number, dto: Partial<CreateTaskDto>): import("./tasks.entity").Task;
    remove(id: number): {
        message: string;
    };
}
