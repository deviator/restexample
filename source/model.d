module model;

import std.math;

import vibe.web.rest;
import vibe.http.common;

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

interface IModel
{
    @method(HTTPMethod.GET)
    float triangleAreaByLengths(float a, float b, float c);
    @method(HTTPMethod.GET)
    float triangleAreaByPoints(Point a, Point b, Point c);
}

class Model : IModel
{
    float triangleAreaByLengths(float a, float b, float c)
    {
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
}
