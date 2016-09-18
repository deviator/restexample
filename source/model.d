module model;

import std.math;
import std.exception;

import vibe.web.rest;
import vibe.http.common;
import vibe.data.json;

struct Point
{
    float x, y;
}

float sqr(float v)
{
    return v * v;
}

float dist()(auto ref const(Point) a, auto ref const(Point) b)
{
    return sqrt(sqr(a.x - b.x) + sqr(a.y - b.y));
}

interface IPointCalculator
{
    struct CollectionIndices
    {
        string _name;
    }

    @method(HTTPMethod.POST)
    Point calc(string _name, Point[] points...);

    // свойства автоматически становятся GET
    string[] names() @property;
}

class PointCalculator : IPointCalculator
{
    Point calc(string _name, Point[] points...)
    {
        import std.algorithm;
        if (_name == "center")
        {
            auto n = points.length;
            float cx = points.map!"a.x".sum / n;
            float cy = points.map!"a.y".sum / n;
            return Point(cx, cy);
        }
        else if (_name == "left")
            return points.fold!((a,b)=>a.x<b.x?a:b);
        else
            throw new Exception("Unknown calculator '" ~ _name ~ "'");
    }

    string[] names() @property
    {
        return ["center", "left"];
    }
}

interface IPointBinOp
{
    @method(HTTPMethod.GET)
    Point add(Point a, Point b);

    @method(HTTPMethod.GET)
    Point sub(Point a, Point b);
}

class PointBinOp : IPointBinOp
{
    Point add(Point a, Point b) { return Point(a.x + b.x, a.y + b.y); }
    Point sub(Point a, Point b) { return Point(a.x - b.x, a.y - b.y); }
}

interface IModel
{
    @method(HTTPMethod.GET)
    float triangleAreaByLengths(float a, float b, float c);

    @method(HTTPMethod.POST)
    float triangleAreaByPoints(Point a, Point b, Point c);

    @method(HTTPMethod.GET)
    Collection!IPointCalculator calculator();

    @method(HTTPMethod.GET)
    IPointCalculator calculator2();

    IPointBinOp op() @property;
}

class Model : IModel
{
    PointCalculator m_pcalc;
    PointBinOp m_pbinop;

    this()
    {
        m_pcalc = new PointCalculator;
        m_pbinop = new PointBinOp;
    }

    float triangleAreaByLengths(float a, float b, float c)
    {
        enforce(a+b>c && a+c>b && b+c>a, "This is not a triangle");
        auto p = (a + b + c) / 2;
        return sqrt(p * (p - a) * (p - b) * (p - c));
    }

    float triangleAreaByPoints(Point a, Point b, Point c)
    {
        auto ab = dist(a, b);
        auto ac = dist(a, c);
        auto bc = dist(b, c);
        return triangleAreaByLengths(ab, ac, bc);
    }

    Collection!IPointCalculator calculator()
    {
        return Collection!IPointCalculator(m_pcalc);
    }

    IPointCalculator calculator2()
    {
        return m_pcalc;
    }

    IPointBinOp op() @property
    {
        return m_pbinop;
    }
}
