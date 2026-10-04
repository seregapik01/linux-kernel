#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

static int __init hello_init(void)
{
    pr_info("Hello World form kernel!\n");
    return 0;
}

static void __exit hello_exit(void)
{
    pr_info("Goodbye from kernel!\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("SERGEI PIKULEV");
MODULE_DESCRIPTION("Simple demo module");
MODULE_VERSION("0.9");