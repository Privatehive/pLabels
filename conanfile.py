#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json, os
from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import copy
from conan.tools.build import cross_building
from conan.tools.env import VirtualBuildEnv

required_conan_version = ">=2.0"


class pLabelsConan(ConanFile):
    jsonInfo = json.load(open("info.json", 'r'))
    # ---Package reference---
    name = jsonInfo["projectName"].lower()
    version = "%u.%u.%u" % (jsonInfo["version"]["major"], jsonInfo["version"]["minor"], jsonInfo["version"]["patch"])
    user = jsonInfo["domain"]
    channel = "%s" % ("snapshot" if jsonInfo["version"]["snapshot"] else "stable")
    # ---Metadata---
    description = jsonInfo["projectDescription"]
    license = jsonInfo["license"]
    author = jsonInfo["vendor"]
    topics = jsonInfo["topics"]
    homepage = jsonInfo["homepage"]
    url = jsonInfo["repository"]
    # ---Requirements---
    requires = ["qt/6.7.2@%s/stable" % user,
                "qtappbase/[~1]@%s/snapshot" % user,
                "materialrally/[~1]@%s/snapshot" % user]
    tool_requires = ["cmake/[>=3.21.7]", "ninja/[>=1.11.1]"]
    # ---Sources---
    exports = ["info.json", "LICENSE"]
    exports_sources = ["info.json", "LICENSE", "*.txt", "src/*"]
    # ---Binary model---
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False], "lto": [True, False]}
    default_options = {
        "shared": True,
        "fPIC": True,
        "lto": False,
        "qtappbase/*:qml": True,
        "qt/*:GUI": True,
        "qt/*:opengl": "desktop",
        "qt/*:qtbase": True,
        "qt/*:qtdeclarative": True,
        "qt/*:qtsvg": True,
        "qt/*:qttranslations": True,
        "qt/*:qt5compat": True,
        "qt/*:quick2style": "material"}
    # ---Build---
    generators = []
    # ---Folders---
    no_copy_source = False

    def requirements(self):
        if self.settings.os == "Windows":
            self.requires("libusb-bin/1.0.27@%s/stable" % self.user)
        else:
            self.requires("libusb/1.0.26@")

    def configure(self):
        self.options["qt"].lto = self.options.lto
        self.options["qtappbase"].lto = self.options.lto
        self.options["materialrally"].lto = self.options.lto
        self.options["qt"].shared = self.options.shared
        self.options["qtappbase"].shared = self.options.shared
        self.options["materialrally"].shared = self.options.shared
        self.options["qt"].fPIC = self.options.fPIC
        self.options["qtappbase"].fPIC = self.options.fPIC
        self.options["materialrally"].fPIC = self.options.fPIC

    def generate(self):
        ms = VirtualBuildEnv(self)
        tc = CMakeToolchain(self, generator="Ninja")
        qml_import_path = []
        for require, dependency in self.dependencies.items():
            path = dependency.runenv_info.vars(self, scope='run').get("QML_IMPORT_PATH")
            if path is not None:
                qml_import_path.append(path.replace(os.sep, '/'))
        tc.variables["QT_QML_OUTPUT_DIRECTORY"] = "${CMAKE_CURRENT_LIST_DIR}/src"
        qml_import_path.append("${QT_QML_OUTPUT_DIRECTORY}")
        tc.variables["QML_IMPORT_PATH"] = ";".join(qml_import_path)
        tc.variables["CMAKE_INTERPROCEDURAL_OPTIMIZATION"] = self.options.lto
        tc.generate()
        ms.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        if self.settings.build_type == 'Release':
            cmake.install(cli_args=["--strip"])
        else:
            cmake.install()
