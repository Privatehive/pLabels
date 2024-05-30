#pragma once
#include <QAbstractListModel>
#include <QObject>
#include <QtQmlIntegration>

class FontfamiliesModel : public QAbstractListModel {

	Q_OBJECT
	QML_NAMED_ELEMENT(FontfamiliesModel)

 public:
	FontfamiliesModel(QObject *pParent = nullptr);
	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex &index, int role) const override;
	QHash<int, QByteArray> roleNames() const override;

 private:
	QStringList m_fontfamilies;
};
