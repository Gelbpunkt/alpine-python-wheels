from packaging import version as get_version
from pkginfo import get_metadata
from os import listdir
from os.path import isfile, join


def clean_name(name):
    return name.replace(";", "")


def clean_requirements(orderlist, keylist, requirements):
    requirements = [
        req for req in requirements if req in keylist and not req in orderlist
    ]
    return requirements


if __name__ == "__main__":
    with open("ignore", "r") as f:
        ignored_names = f.read().splitlines()

    whl_folder = "wheels"
    whl_files = [
        file
        for file in listdir(whl_folder)
        if isfile(join(whl_folder, file)) and file.endswith(".whl")
    ]

    whl_metadatas = []
    name_to_version = dict()
    name_to_file = dict()
    for file in whl_files:
        metadata = get_metadata(join(whl_folder, file))
        version = get_version.parse(metadata.version)
        if metadata.name not in ignored_names and (
            ((current_version := name_to_version.get(metadata.name, None)) is None)
            or version > current_version
        ):
            whl_metadatas.append(metadata)
            name_to_file[metadata.name] = file
            name_to_version[metadata.name] = version

    requirements = dict(
        (clean_name(md.name), [clean_name(req.split()[0]) for req in md.requires_dist])
        for md in whl_metadatas
    )

    whl_order = []

    max_iterations = 10

    for iteration in range(max_iterations):
        keys = requirements.keys()
        if not keys:
            break

        for key in keys:
            reqs = clean_requirements(whl_order, keys, requirements[key])
            if reqs:
                requirements[key] = reqs
            else:
                whl_order.append(key)

        for name in whl_order:
            if name in keys:
                del requirements[name]

    if requirements.keys():
        print("Error: Failed to order:", *requirements.keys())

    print(*[name_to_file[key] for key in whl_order], sep="\n")
