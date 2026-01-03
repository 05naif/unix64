SRCS = p.s makewords.s #lowercase.o sort.o
OBJS = $(SRCS:.s=.o)
OBJS := $(addprefix ../objs/, $(OBJS))
BINS = p makewords #lowercase sort
BINS := $(addprefix ../bin/, $(BINS))

all: $(BINS)

../bin/%: ../objs/%.o
	ld $< -o $@
../objs/%.o: %.s
	as $< -o $@ -g
clean:
	rm -rf $(OBJS) $(BINS)
