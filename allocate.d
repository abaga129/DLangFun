import std.stdio;
import std.experimental.allocator;
import std.typecons : Ternary;
import core.stdc.stdlib;

/// Driver function
void main(string[] args)
{
    /// After main exits, use the original allocator
    auto oldAllocator = theAllocator;
    scope(exit) theAllocator = oldAllocator;
    
    /// Create an instance of MyAllocator and then assign the
    /// allocator for this thread to MyAllocator.
    MyAllocator allocator = new MyAllocator();
    theAllocator = allocator;
    
    /// Allocate various types
    int *i = theAllocator.make!int(20);
    double *d = theAllocator.make!double(10.0003);
    float[] arr = theAllocator.makeArray!float(10, 3.0f);
    foo* f = theAllocator.make!foo;
    f.test = 15;
    
    writefln("Integer allocated using c runtime: %s", *i);
    writefln("Double allocated using c runtime: %s", *d);
    writefln("Array of 10 floats allocated using c runtime: %s", arr);
    writefln("Field of a struct allocated using c runtime: %s", f.test);
    
    theAllocator.dispose(i);
    writefln("%s", *i);
}

class MyAllocator : IAllocator
{
public:
nothrow:
@nogc:
    
    override uint alignment() @property
    {
        return _alignment;
    }
    
    override ulong goodAllocSize(ulong s)
    {
        return 0;
    }
    
    override void[] allocate(ulong n, TypeInfo ti = null)
    {
        ulong a;
        if(ti)
           a = ti.tsize;
        else
           a = 4;
        
        void* mem = malloc(n * a);
        _alignment = cast(uint)a;
        return mem[0..n];
    }
    
    override void[] alignedAllocate(ulong n, uint a)
    {
        void* mem;
        _alignment = a;
        if(a == 1)
        {
            mem = cast(void*)malloc(n);
            return mem[0..n];
        }
        else
        {
            size_t size = n + a - 1 + size_t.sizeof * 2; 
            mem = malloc(size);
            return mem[0..n];
        }
    }
    
    override void[] allocateAll()
    {
        return null;
    }
    
    override bool expand(ref void[], ulong)
    {
        return 0;
    }
    
    override bool reallocate(ref void[] mem, ulong n)
    {
        if(mem)
        {
            realloc(mem.ptr, n);
        }
        return false;
    }
    
    override bool alignedReallocate(ref void[] b, ulong size, uint alignment)
    {
        return 0;
    }
    
    override Ternary owns(void[] b)
    {
        return Ternary.unknown;
    }
        
    override Ternary resolveInternalPointer(void* p, ref void[] result)
    {
        return Ternary.unknown;
    }
    
    override bool deallocate(void[] b)
    {
        if(b)
        {
            free(b.ptr);
            return true;
        }
        return false;
    }
    
    override bool deallocateAll()
    {
        return 0;
    }
    
    override Ternary empty()
    {
        return Ternary.unknown;
    }
    
private:
    uint _alignment; 
}

struct foo
{
    int test;
}
