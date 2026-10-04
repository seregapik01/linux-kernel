// SPDX-License-Identifier: GPL-2.0
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>

#define MY_STR_MAX 64

static char my_str[MY_STR_MAX];
static int idx;
static int ch_val;

static int idx_set(const char *val, const struct kernel_param *kp) {
    int ret;

    ret = kstrtoint(val, 10, &idx);
    if (ret) {
        pr_err("idx: failed to parse number '%s'\n", val);
        return ret;
    }

    if (idx < 0 || idx >= MY_STR_MAX - 1) {
        pr_err("idx: %d out of range [0; %d]\n", idx, MY_STR_MAX - 2);
        return -EINVAL;
    }

    pr_info("idx set to %d\n", idx);
    return 0;
}

static int idx_get(char *buffer, const struct kernel_param *kp) {
    return sprintf(buffer, "%d\n", idx);
}

static const struct kernel_param_ops idx_ops = {
    .set = idx_set,
    .get = idx_get,
};

module_param_cb(idx, &idx_ops, &idx, 0664);
MODULE_PARM_DESC(idx, "Character index in my_str string (0..62)");

static int ch_val_set(const char *val, const struct kernel_param *kp) {
    int ret;

    ret = kstrtoint(val, 10, &ch_val);
    if (ret) {
        pr_err("ch_val: failed to parse number '%s'\n", val);
        return ret;
    }

    if (ch_val < 32 || ch_val > 126) {
        pr_err("ch_val: %d out of printable ASCII range [32; 126]\n", ch_val);
        return -EINVAL;
    }

    my_str[idx] = (char)ch_val;

    pr_info("ch_val=%d -> my_str[%d]='%c'\n", ch_val, idx, ch_val);
    return 0;
}

static int ch_val_get(char *buffer, const struct kernel_param *kp) {
    return sprintf(buffer, "%d\n", ch_val);
}

static const struct kernel_param_ops ch_val_ops = {
    .set = ch_val_set,
    .get = ch_val_get,
};

module_param_cb(ch_val, &ch_val_ops, &ch_val, 0664);
MODULE_PARM_DESC(ch_val, "ASCII code of printable character (32..126)");

module_param_string(my_str, my_str, MY_STR_MAX, 0444);
MODULE_PARM_DESC(my_str, "Resulting string (read-only)");

static int __init my_module_init(void) {
    pr_info("init\n");
    return 0;
}

static void __exit my_module_exit(void) {
    pr_info("exit\n");
}

module_init(my_module_init);
module_exit(my_module_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("SERGEI PIKULEV");
MODULE_DESCRIPTION("Parameterized Hello, World! module");
MODULE_VERSION("0.9");
