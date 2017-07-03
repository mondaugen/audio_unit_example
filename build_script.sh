mkdir -p ./bin
clang++ -c -ObjC++ signal_chain.m -o signal_chain.o -g
clang++ -c -ObjC++ DSPKernel.mm -o DSPKernel.o -g
clang++ -c -ObjC++ FilterDemo.mm -o FilterDemo.o -g
clang++ signal_chain.o DSPKernel.o FilterDemo.o -o bin/signal_chain \
    -framework Foundation -framework AudioToolbox -framework AVFoundation \
