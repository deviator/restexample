import std.stdio;

import model;

version (server)
{
    import vibe.d;
    shared static this()
    {
        auto router = new URLRouter;

        router.registerRestInterface(new Model);

        auto restset = new RestInterfaceSettings;
        restset.baseURL = URL("http://127.0.0.1:8080/");
        router.get("/model.js", serveRestJSClient!IModel(restset));
        router.get("/", staticTemplate!"index.dt");

        auto set = new HTTPServerSettings;
        set.port = 8080;
        set.bindAddresses = ["127.0.0.1"];

        listenHTTP(set, router);
    }

    void ddd(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        writeln(req);
        writeln("json: ", req.json);
        writeln("params: ", req.params);
        writeln("path: ", req.path);
        writeln("query: ", req.query);
        writeln("headers: ", req.headers);
        writeln("method: ", req.method);
        writeln("requestURL: ", req.requestURL);
        writeln("fullURL: ", req.fullURL);
        writeln(req.bodyReader.readAllUTF8);
        res.writeJsonBody(Point(666,666));
    }
}
else
{
    void main()
    {
        auto a = Point(1, 2);
        auto b = Point(3, 4);
        auto c = Point(4, 1);

        version (client)
        {
            import vibe.web.rest;
            auto m = new RestInterfaceClient!IModel("http://127.0.0.1:8080/");
        }
        else // единое приложение
            auto m = new Model;

        writeln(m.triangleAreaByPoints(a, b, c));
        writeln(m.op.sum(a,b));
        writeln(m.op.dif(c,a));
        writeln(m.calculator2.names);
        writeln(m.calculator2.calc("left", a, b, c));
        writeln(m.calculator2.calc("center", a, b, c, m.op.sum(a,b)));

        version (client)
        {
            writeln(m.calculator.names);
            writeln(m.calculator["left"].calc(a, b, c));
            writeln(m.calculator["center"].calc(a, b, c, m.op.sum(a,b)));
        }
    }
}
