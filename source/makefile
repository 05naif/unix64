SRCS = p.s makewords.s lowercase.o
OBJS = $(SRCS:.s=.o)
OBJS := $(addprefix ../objs/, $(OBJS))
BINS = p makewords lowercase
BINS := $(addprefix ../bin/, $(BINS))

all: $(BINS)

../bin/%: ../objs/%.o
	ld $< -o $@
../objs/%.o: %.s
	as $< -o $@
clean:
	rm -rf $(OBJS) $(BINS)
