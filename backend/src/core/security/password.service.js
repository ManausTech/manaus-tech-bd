import bcrypt from "bcrypt";


async function hashPassword(password) {
    return await bcrypt.hash(password, 10);

}
async function comparePassword(password, hashedpassword) {
    return await bcrypt.compare(password, hashedpassword);
}

export {
    hashPassword,
    comparePassword
}