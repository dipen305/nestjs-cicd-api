import { CreateTaskDto } from './dto/create-task.dto';
import { Task } from './tasks.entity';
export declare class TasksService {
    private tasks;
    private nextId;
    findAll(): Task[];
    findOne(id: number): Task;
    create(dto: CreateTaskDto): Task;
    update(id: number, dto: Partial<CreateTaskDto>): Task;
    remove(id: number): void;
}
