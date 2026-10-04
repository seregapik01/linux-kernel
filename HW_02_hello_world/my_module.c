#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

static int __init hello_init(void)
{
    return 0;
}

static void __exit hello_exit(void)
{
    //
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("SERGEI PIKULEV");
MODULE_DESCRIPTION("Simple demo module");
MODULE_VERSION("0.9");