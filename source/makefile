srcs = p.s
objs = ../objs/p.o
exec = ../bin/p

$(exec): $(objs)
	ld $< -o $@

$(objs): $(srcs)
	as $< -o $@

clean:
	rm -rf $(objs) $(exec)
