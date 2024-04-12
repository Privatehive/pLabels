#include "TapeModel.h"
#include "Roles.h"
extern "C" {
#include "ptouchwrapper.h"
}


TapeModel::TapeModel(QObject *pParent) : QAbstractListModel(pParent) {}

int TapeModel::rowCount(const QModelIndex &parent) const {

	for(auto i = 0;; i++) {
		if(tape_info[i].mm == 0 && tape_info[i].px == 0 && tape_info[i].margins == 0.) {
			return i;
		}
	}
}

QVariant TapeModel::data(const QModelIndex &index, int role) const {

	const auto row = index.row();
	const auto column = index.column();
	auto ret = QVariant();
	if(column == 0 && row < rowCount({})) {
		switch(role) {
			case Qt::DisplayRole:
				ret = QVariant::fromValue(QString("%1 mm").arg(tape_info[row].mm));
				break;
			case Enums::TapeMarginsMmRole:
				ret = QVariant::fromValue(tape_info[row].margins);
				break;
			case Enums::TapeWidthMmRole:
				ret = QVariant::fromValue(tape_info[row].mm);
				break;
			case Enums::TapeWidthPxRole:
				ret = QVariant::fromValue(tape_info[row].px);
				break;
			default:
				ret = QVariant();
		}
	}
	return ret;
}

QHash<int, QByteArray> TapeModel::roleNames() const {

	QHash<int, QByteArray> ret;
	ret.insert(Qt::DisplayRole, {"name"});
	ret.insert(Enums::TapeWidthMmRole, {"tapeWidthMm"});
	ret.insert(Enums::TapeWidthPxRole, {"tapeWidthPx"});
	ret.insert(Enums::TapeMarginsMmRole, {"tapeMarginsMm"});
	return ret;
}