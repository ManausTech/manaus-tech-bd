import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg'
import { PrismaClient } from '@prisma/client'

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
const prisma = global.prismaClient || new PrismaClient({ adapter });

if (process.env.NODE_ENV !== 'production') {
    global.prismaClient = prisma;
}

export default prisma

