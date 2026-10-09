import express from "express";
import signUpRouter from "./features/signup/signup.route.js";
import signInRouter from "./features/signin/signin.route.js";

const app = express();

const PORT = process.env.PORT || 8081;

app.use(express.json());

//Rotas publicas
app.use('/signup', signUpRouter);
app.use('/signin', signInRouter);

//Rotas privadas (usar authMiddleWare aqui quando existirem)


app.listen(PORT, () => {
    console.log(`servidor iniciado em http://localhost:${PORT}`);
});
