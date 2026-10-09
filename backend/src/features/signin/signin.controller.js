import signIn from "./signin.service.js";

async function signinController(req, res) {
    try {
        const { email, password } = req.body;
        const result = await signin(email, password);
        res.status(200).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
}

export default signinController;
