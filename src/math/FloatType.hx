package math;

#if (hl || cpp)
typedef FloatType = Single;
#else
typedef FloatType = Float;
#end
