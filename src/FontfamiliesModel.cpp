//
// Created by bjoern on 15.05.24.
//

#include "FontfamiliesModel.h"
#include <QFontDatabase>

FontfamiliesModel::FontfamiliesModel(QObject *pParent) : QAbstractListModel(pParent), m_fontfamilies(QFontDatabase::families()) {}

int FontfamiliesModel::rowCount(const QModelIndex &parent) const {

	return m_fontfamilies.size();
}

QVariant FontfamiliesModel::data(const QModelIndex &index, int role) const {

	const auto row = index.row();
	const auto column = index.column();
	auto ret = QVariant();
	if(column == 0 && row < rowCount({})) {
		switch(role) {
			case Qt::DisplayRole:
				ret = QVariant::fromValue(m_fontfamilies.at(row));
				break;
			default:
				ret = QVariant();
		}
	}
	return ret;
}

QHash<int, QByteArray> FontfamiliesModel::roleNames() const {

	QHash<int, QByteArray> ret;
	ret.insert(Qt::DisplayRole, {"family"});
	return ret;
}