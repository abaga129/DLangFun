/*******************************************************************************
 * Author: Ethan Reker
 * License: MIT
 * Copyright: 2017 Ethan Reker
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
 * copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so.

 ******************************************************************************/
import std.stdio;

/// Dummy functions for testing
void foo() @nogc @safe {}
void foo2() nothrow @safe {}

/// Main Driver function
void main()
{
    /// Run the the factorial example and have it calculate 10!
    enum int fact = Factorial!(10).result;
    static assert(fact == 3628800);
    
    /// Test to see if the function foo has the @nogc attribute
    enum bool nogc = FunctionInfo!(foo).isNoGC();
    static assert(nogc);
    
    /// Test to see if the function foo has the @system attribute
    enum bool system = FunctionInfo!(foo2).isSystem();
    static assert(!system);
    pragma(msg, "foo2 is @system? ", system);
}

/// Templates can be recursive as this example shows.
template Factorial(int N)
{
    static assert(N > -1);
    
    static if(N == 0)
        static const int result = 1;
    else
        static const int result = Factorial!(N - 1).result * N;
}

/// Template for checking function attributes
template FunctionInfo(alias funcName)
{
    /// returns true if funcName is @nogc
    bool isNoGC()
    {
        foreach(string s; __traits(getFunctionAttributes, funcName))
        {
            if(s == "@nogc")
                return true;
        }
        return false;
    }
    
    /// returns true if funcName is @system
    bool isSystem()
    {
        foreach(string s; __traits(getFunctionAttributes, funcName))
        {
            if(s == "@system")
                return true;
        }
        return false;
    }
}
