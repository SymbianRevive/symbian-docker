#!/usr/bin/env python3
from pathlib import Path
import subprocess


def main():
    from argparse import ArgumentParser

    parser = ArgumentParser(prog="autocmake", description="Configure and build a cmake project in one step")
    parser.add_argument("-S", metavar="SOURCEDIR", type=Path, required=True, help="source directory")
    parser.add_argument("-B", metavar="BUILDDIR", type=Path, required=True, help="build directory")
    parser.add_argument("--config", type=str, required=True, help="build configuration")
    parser.add_argument("--preset", type=str, required=False, help="preset")
    parser.add_argument("--parallel", "-j", metavar="JOBS", nargs="?", type=int, default=1, help="parallel build")
    parser.add_argument("--verbose", "-v", action="store_true", help="be verbose")
    parser.add_argument("--clean-first", action="store_true", help="clean first")
    parser.add_argument("--target", "-t", nargs="+", required=False, help="target(s) to build")
    parser.add_argument("--multi-config", action="store_true", help="enable multi-configuration build")
    args, rest = parser.parse_known_args()

    config_args = [
        "cmake",
        "-B", str(args.B),
        "-S", str(args.S),
        "-G", "Ninja Multi-Config" if args.multi_config else "Ninja",
    ]
    if not args.multi_config:
        config_args.append(f"-DCMAKE_BUILD_TYPE={args.config}")
    config_args += rest
    subprocess.check_call(config_args)

    build_args = [
        "cmake",
        "--build", str(args.B),
        "--config", args.config, 
        "--parallel", str(args.parallel),
    ]
    if args.preset:
        build_args.append("--preset")
        build_args.append(args.preset)
    if args.verbose:
        build_args.append("--verbose")
    if args.clean_first:
        build_args.append("--clean-first")
    if args.target:
        for target in args.target:
            build_args.append("--target")
            build_args.append(target)
    subprocess.check_call(build_args)


if __name__ == "__main__":
    main()
