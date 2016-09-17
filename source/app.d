import std.stdio;

import model;

version (server)
{
    import vibe.d;
    shared static this()
    {
        //auto restset = new RestInterfaceSettings;
        //restset.baseURL("http://127.0.0.1:8080");

        auto router = new URLRouter;

        //router.get("/test.js", serveRestJSClient!IModel(restset));
        //router.registerRestInterface(new Model, restset);
        router.registerRestInterface(new Model);

        auto set = new HTTPServerSettings;
        set.port = 8080;
        set.bindAddresses = ["127.0.0.1"];

        listenHTTP(set, router);
    }
}
else // единое приложение
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
    else
        auto m = new Model;

    writeln(m.triangleAreaByPoints(a, b, c));
}
}
