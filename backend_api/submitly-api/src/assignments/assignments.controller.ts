import { Controller, Get, Post, Patch, Body, Param, Query } from '@nestjs/common';
import { AssignmentsService } from './assignments.service';

@Controller('assignments')
export class AssignmentsController {
  constructor(private readonly assignmentsService: AssignmentsService) {}

  @Post()
  create(@Body() body: any) {
    return this.assignmentsService.create(body);
  }

  @Get()
  findByUser(@Query('userId') userId: string) {
    return this.assignmentsService.findByUser(userId);
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body('status') status: string) {
    return this.assignmentsService.updateStatus(id, status);
  }
}