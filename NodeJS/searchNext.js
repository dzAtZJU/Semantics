import Realm from "realm";

const app = new Realm.App({ id: "semantics-tonbj" });

async function login() {
    const credentials = Realm.Credentials.anonymous();
    const user = await app.logIn(credentials);
    console.log(`Logged in with the user id: ${user.id}`);
};

login()