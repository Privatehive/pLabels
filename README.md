## pLabels

#### Create labels and print them on Brother P-touch® printers

Brother doesn't offer a labeling tool that runs on Linux, so I made it for them. This tool is based
on [ptouch-print](https://dominic.familie-radermacher.ch/projekte/ptouch-print/) and puts a Qt GUI on top.

![pLabels](https://github.com/user-attachments/assets/05cacbdc-5d09-4e28-9bba-2fdc0c6fb0f2)

---

| os      | arch     | CI Status                                                                                                                                                                                                                                               |
|---------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Linux` | `x86_64` | [![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/Privatehive/pLabels/main.yml?branch=master&style=flat&logo=github&label=create+package)](https://github.com/Privatehive/pLabels/actions?query=branch%3Amaster) |

### Features

* Vector based editor
* Add text boxes and customize:
    * font family
    * rotation
    * style: bold, italic, underline
    * alignment: left, mid, right
    * position and scaling
* Print the label with/without dithering
* Save labels as .lbl file
* Supported label sizes (depends on printer): 4 mm, 6 mm, 9 mm, 12 mm, 18 mm, 24 mm, 36 mm
* Supported printers: PT-2420PC, PT-2450PC, PT-1950, PT-2700, PT-1230PC, PT-2430PC, PT-1230PC (PLite Mode), PT-2430PC (
  PLite Mode), PT-2730, PT-H500, PT-E500, PT-P700, PT-P750W, PT-P700 (PLite Mode), PT-P750W (PLite Mode), PT-D410,
  PT-D450, PT-D460BT, PT-D600, PT-D610BT, PT-P710BT

### Planned Features

* Add images
* Add icons, shapes
* Add barcodes
* More dithering algorithms
* Windows installer

### Usage

Just running pLabels AppImage should be enough but...

* Make sure [FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE) is installed.
* If nothing happens, run pLabels from terminal. The error message provides information about the problem.
* If the printer is not found, put this
  [71-brother-ptouch.rules](https://github.com/Privatehive/pLabels/blob/40ed233bdd0af4f758ec179224aff3cd95a1435e/share/71-brother-ptouch.rules)
  udev rule file into the /etc/udev/rules.d dir
