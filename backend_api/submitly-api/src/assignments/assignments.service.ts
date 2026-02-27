import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AssignmentsService {
  constructor(private prisma: PrismaService) {}

  async create(data: any) {
    return this.prisma.assignment.create({
      data: {
        title: data.title,
        description: data.description || null,
        dueDate: new Date(data.dueDate),
        userId: data.userId,
        subjectId: data.subjectId,
      },
    });
  }

  async findByUser(userId: string) {
    return this.prisma.assignment.findMany({
      where: { userId },
      orderBy: { dueDate: 'asc' },
      include: { subject: true },
    });
  }

  async updateStatus(id: string, status: string) {
    return this.prisma.assignment.update({
      where: { id },
      data: { status },
    });
  }
}