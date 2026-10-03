import prisma from "../../../core/database/prisma.client.js"


/**
 * Listagem de usuarios com campos id,username,status
 */
async function listUsers() {
    return prisma.users.findMany({
        select: {
            id: true,
            username: true,
            status: true
        }
    });
}

/**
 * validar por usuario e senha
 */
async function validateUser(username, password) {
    const user = await prisma.users.findFirst({
        where: {
            username,
            password
        }
    });

    return !!user;
}

/**
 * função de criar usuario
 */
async function createUser(data) {
    return prisma.users.create({
        data,
        select: {
            id: true,
            username: true,
            status: true
        }
    });
}

/**
 *Validar se o email ja existe
 */
async function validateByEmail(email) {
    const user = await prisma.users.findFirst({
        where: {
            email
        }
    });

    return !!user;
}

/**
 * Função para recuperar dados do usuario pelo email 
 * Ultimo contribuidor: Kevin da Costa Vinagre
 * Ultima edição: 28/09/2026-20:38
 * Contribuidores:
 * -Kevin da Costa Vinagre
 */
async function findByEmail(email) {
    const user = await prisma.users.findFirst({
        where: {
            email
        }
    });
           if (!user) return null;
       return { ...user, id: user.id.toString() };
}

/**
 *Validar se o Nome de usuario ja existe
 */
async function validateByUsername(username) {
    const user = await prisma.users.findFirst({
        where: {
            username
        }
    });

    return !!user;
}

export {
    listUsers,
    validateUser,
    createUser,
    validateByEmail,
    validateByUsername,
    findByEmail
}