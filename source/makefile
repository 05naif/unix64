SRCS = p.s makewords.s
OBJS = $(SRCS:.s=.o)
OBJS := $(addprefix ../objs/, $(OBJS))
BINS = p makewords
BINS := $(addprefix ../bin/, $(BINS))

all: $(BINS)

../bin/%: ../objs/%.o
	ld $< -o $@
../objs/%.o: %.s
	as $< -o $@
clean:
	rm -rf $(OBJS) $(BINS)
