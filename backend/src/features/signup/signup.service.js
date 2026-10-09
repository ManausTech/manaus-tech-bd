import { hashPassword } from '../../core/security/password.service.js';
import { validateByEmail, validateByUsername, createUser } from '../../shared/users/repositories/users.repository.js'


async function signUpUser(username, email, password) {
    if (!username || !email || !password) {
        const error = new Error("Campos nome de usuario, email e senha são obrigatorios");
        error.statusCode = 500;
        throw error;
    }
    if (await validateByUsername(username)) {
        const error = new Error("Nome de usuario ja cadastrado");
        error.statusCode = 409;
        throw error;
    }
    if (await validateByEmail(email)) {
        const error = new Error("Email ja registrado");
        error.statusCode = 409;
        throw error;
    }
    try {
        const hashpassword = await hashPassword(password);
        const user = await createUser({
            username,
            email,
            password: hashpassword
        });
        return { ...user, id: user.id.toString() };
    } catch (issue) {
        const error = new Error("Falha ao comunicar com banco de dados");
        error.statusCode = 509;
        throw error;
    }
}

export default signUpUser