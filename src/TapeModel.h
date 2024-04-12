#pragma once
#include <QAbstractItemModel>
#include <QtQmlIntegration>

class TapeModel : public QAbstractListModel {

	Q_OBJECT
	QML_NAMED_ELEMENT(TapeModel)

 public:
	TapeModel(QObject *pParent = nullptr);

	int rowCount(const QModelIndex &parent) const override;

	QVariant data(const QModelIndex &index, int role) const override;

	QHash<int, QByteArray> roleNames() const override;
};
