import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, roc_curve, auc
from sklearn.impute import SimpleImputer
import warnings
warnings.filterwarnings('ignore')

print("1. ЗАГРУЗКА И ПРЕДОБРАБОТКА ДАННЫХ")
print("=" * 50)

csvFilePath = "data/Covid Data.csv"
csvData = pd.read_csv(csvFilePath, low_memory=False)


print(f"Размер датасета: {csvData.shape}")
print(f"Количество признаков: {csvData.shape[1]}")
print(f"Количество записей: {csvData.shape[0]}")

print("\nИнформация о датасете:")
print(csvData.info())

print("\nПропущенные значения:")
missing_values = csvData.isnull().sum()
print(missing_values[missing_values > 0])

print("\n2. АНАЛИЗ ЗАВИСИМОСТЕЙ И ВИЗУАЛИЗАЦИЯ")
print("=" * 50)

numeric_columns = csvData.select_dtypes(include=[np.number]).columns
print(f"Числовые колонки: {len(numeric_columns)}")

numeric_data = csvData[numeric_columns].copy()
# Fill missing values for correlation analysis
imputer_temp = SimpleImputer(strategy='median')
numeric_data_imputed = pd.DataFrame(imputer_temp.fit_transform(numeric_data),
                                    columns=numeric_data.columns)

plt.figure(figsize=(20, 18))
correlation_matrix = numeric_data_imputed.corr()
sns.heatmap(correlation_matrix, cmap='coolwarm', center=0,
            square=True, linewidths=0.5, annot=False,
            xticklabels=True, yticklabels=True)
plt.title('Матрица корреляции числовых признаков', fontsize=16, pad=20)
plt.xticks(rotation=45, ha='right', fontsize=10)
plt.yticks(rotation=0, fontsize=10)
plt.tight_layout()
plt.savefig('correlation_matrix.png', dpi=300, bbox_inches='tight')
plt.show()

correlation_pairs = []
for i in range(len(correlation_matrix.columns)):
    for j in range(i+1, len(correlation_matrix.columns)):
        corr_value = abs(correlation_matrix.iloc[i, j])
        if corr_value > 0.5:
            correlation_pairs.append((
                correlation_matrix.columns[i],
                correlation_matrix.columns[j],
                correlation_matrix.iloc[i, j]
            ))

print("\nНаиболее коррелирующие пары признаков (|corr| > 0.5):")
for col1, col2, corr in sorted(correlation_pairs, key=lambda x: abs(x[2]), reverse=True)[:10]:
    print(f"{col1} - {col2}: {corr:.3f}")

if correlation_pairs:
    top_pairs = sorted(correlation_pairs, key=lambda x: abs(x[2]), reverse=True)[:4]

    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    axes = axes.ravel()

    for idx, (col1, col2, corr) in enumerate(top_pairs):
        # Sample data if too many points for better visualization
        if len(numeric_data_imputed) > 10000:
            sample_idx = np.random.choice(len(numeric_data_imputed), 10000, replace=False)
            sample_data = numeric_data_imputed.iloc[sample_idx]
        else:
            sample_data = numeric_data_imputed
            
        axes[idx].scatter(sample_data[col1], sample_data[col2],
                          alpha=0.5, s=10)
        axes[idx].set_xlabel(col1, fontsize=9)
        axes[idx].set_ylabel(col2, fontsize=9)
        axes[idx].set_title(f'{col1} vs {col2}\ncorr = {corr:.3f}', fontsize=10)

    plt.tight_layout()
    plt.savefig('correlation_scatter_plots.png', dpi=300, bbox_inches='tight')
    plt.show()

print("\n3. ВЫБОР ЦЕЛЕВОГО СТОЛБЦА")
print("=" * 50)

potential_targets = ['ICU', 'DATE_DIED', 'INTUBED', 'CLASIFFICATION_FINAL']

for target in potential_targets:
    if target in csvData.columns:
        print(f"\nАнализ '{target}':")
        print(f"Уникальные значения: {csvData[target].nunique()}")
        print(f"Распределение:")
        print(csvData[target].value_counts().head())

# Используем ICU как целевой столбец - интересно предсказать, потребуется ли пациенту интенсивная терапия
target_column = 'ICU'
print(f"\nВыбран целевой столбец: '{target_column}'")

print("\nПодготовка данных...")

y = csvData[target_column].copy()

# Remove rows with missing/unknown values (97, 98, 99)
mask = ~y.isin([97, 98, 99])
csvData_filtered = csvData[mask].copy()
y_filtered = y[mask].copy()

# Convert to binary classification: 1 = ICU needed, 2 = No ICU needed
y_filtered = (y_filtered == 1).astype(int)  # 1 = ICU, 2 = No ICU

print(f"\nПосле фильтрации:")
print(f"Размер данных: {csvData_filtered.shape}")
print(f"Распределение классов ICU:")
print(pd.Series(y_filtered).value_counts())
print(f"Процент нуждающихся в ICU: {y_filtered.mean()*100:.2f}%")

y_encoded = y_filtered.values
le = None  # Don't need label encoder for binary classification

print(f"Количество классов: 2")
print(f"Классы: No ICU (0), ICU (1)")

# Select numeric columns from filtered data
numeric_columns_filtered = csvData_filtered.select_dtypes(include=[np.number]).columns
numeric_data_filtered = csvData_filtered[numeric_columns_filtered].copy()

# Exclude target column and other problematic columns
columns_to_exclude = ['DATE_DIED', target_column]
numeric_data_filtered = numeric_data_filtered.drop(columns=[col for col in columns_to_exclude if col in numeric_data_filtered.columns])

# Fill missing values with median
imputer = SimpleImputer(strategy='median')
numeric_data_imputed = pd.DataFrame(imputer.fit_transform(numeric_data_filtered),
                                    columns=numeric_data_filtered.columns)

X = numeric_data_imputed.copy()

print(f"Финальная размерность признаков: {X.shape}")

print("\n4. ОБУЧЕНИЕ МОДЕЛЕЙ МАШИННОГО ОБУЧЕНИЯ")
print("=" * 50)

X_train, X_test, y_train, y_test = train_test_split(
    X, y_encoded, test_size=0.3, random_state=42, stratify=y_encoded
)

print(f"Размер тренировочной выборки: {X_train.shape}")
print(f"Размер тестовой выборки: {X_test.shape}")

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

models = {
    'Random Forest': RandomForestClassifier(
        n_estimators=100,
        max_depth=15,
        min_samples_split=20,
        min_samples_leaf=10,
        max_features='sqrt',
        random_state=42,
        n_jobs=-1,
        class_weight='balanced'
    ),
    'Gradient Boosting': GradientBoostingClassifier(
        n_estimators=100,
        max_depth=6,
        min_samples_split=20,
        min_samples_leaf=10,
        learning_rate=0.1,
        subsample=0.8,
        random_state=42
    ),
    'Logistic Regression': LogisticRegression(
        C=1.0,
        max_iter=1000,
        random_state=42,
        n_jobs=-1,
        class_weight='balanced'
    )
}

results = {}

for name, model in models.items():
    print(f"\nОбучение модели: {name}")

    cv_scores = cross_val_score(model, X_train_scaled, y_train, cv=5, scoring='accuracy')

    model.fit(X_train_scaled, y_train)

    y_pred = model.predict(X_test_scaled)
    y_pred_proba = model.predict_proba(X_test_scaled) if hasattr(model, "predict_proba") else None

    accuracy = accuracy_score(y_test, y_pred)

    results[name] = {
        'model': model,
        'cv_mean': cv_scores.mean(),
        'cv_std': cv_scores.std(),
        'accuracy': accuracy,
        'y_pred': y_pred,
        'y_pred_proba': y_pred_proba
    }

    print(f"Кросс-валидация (accuracy): {cv_scores.mean():.4f} (+/- {cv_scores.std() * 2:.4f})")
    print(f"Точность на тесте: {accuracy:.4f}")

print("\n5. СРАВНЕНИЕ МОДЕЛЕЙ И ВЫБОР ЛУЧШЕЙ")
print("=" * 50)

comparison_df = pd.DataFrame({
    'Model': list(results.keys()),
    'CV Mean Accuracy': [results[name]['cv_mean'] for name in results.keys()],
    'CV Std': [results[name]['cv_std'] for name in results.keys()],
    'Test Accuracy': [results[name]['accuracy'] for name in results.keys()]
})

print("Сравнение моделей:")
print(comparison_df.sort_values('Test Accuracy', ascending=False))

plt.figure(figsize=(16, 10))

plt.subplot(2, 2, 1)
models_names = list(results.keys())
test_accuracies = [results[name]['accuracy'] for name in models_names]
cv_accuracies = [results[name]['cv_mean'] for name in models_names]

x_pos = np.arange(len(models_names))
width = 0.35

plt.bar(x_pos - width/2, test_accuracies, width, label='Test Accuracy', alpha=0.8)
plt.bar(x_pos + width/2, cv_accuracies, width, label='CV Accuracy', alpha=0.8)
plt.xlabel('Models')
plt.ylabel('Accuracy')
plt.title('Сравнение точности моделей')
plt.xticks(x_pos, models_names, rotation=45)
plt.legend()
plt.grid(True, alpha=0.3)

best_model_name = max(results.items(), key=lambda x: x[1]['accuracy'])[0]
best_model_results = results[best_model_name]

plt.subplot(2, 2, 2)
cm = confusion_matrix(y_test, best_model_results['y_pred'])
class_names = ['No ICU', 'ICU'] if le is None else le.classes_
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=class_names, yticklabels=class_names)
plt.title(f'Матрица ошибок: {best_model_name}')
plt.xlabel('Предсказанные')
plt.ylabel('Фактические')

plt.subplot(2, 2, 3)
if best_model_results['y_pred_proba'] is not None:
    from sklearn.metrics import roc_auc_score
    
    # For binary classification
    fpr, tpr, _ = roc_curve(y_test, best_model_results['y_pred_proba'][:, 1])
    roc_auc = auc(fpr, tpr)
    
    plt.plot(fpr, tpr, color='darkorange', lw=2,
             label=f'ROC (AUC = {roc_auc:0.3f})')
    
    plt.plot([0, 1], [0, 1], 'k--', lw=2)
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title(f'ROC-кривая: {best_model_name}')
    plt.legend(loc="lower right")
    plt.grid(True, alpha=0.3)
else:
    plt.text(0.5, 0.5, 'ROC недоступна', ha='center', va='center')

plt.subplot(2, 2, 4)
if hasattr(best_model_results['model'], 'feature_importances_'):
    # For tree-based models (Random Forest, Gradient Boosting)
    feature_importance = pd.DataFrame({
        'feature': X.columns,
        'importance': best_model_results['model'].feature_importances_
    }).sort_values('importance', ascending=False).head(15)

    plt.barh(feature_importance['feature'], feature_importance['importance'])
    plt.xlabel('Важность', fontsize=10)
    plt.title(f'Топ-15 важных признаков: {best_model_name}', fontsize=11)
    plt.xticks(fontsize=9)
    plt.yticks(fontsize=8)
    plt.gca().invert_yaxis()
elif hasattr(best_model_results['model'], 'coef_'):
    # For Logistic Regression
    feature_importance = pd.DataFrame({
        'feature': X.columns,
        'importance': np.abs(best_model_results['model'].coef_[0])
    }).sort_values('importance', ascending=False).head(15)

    plt.barh(feature_importance['feature'], feature_importance['importance'])
    plt.xlabel('Важность (абсолютное значение коэффициентов)', fontsize=9)
    plt.title(f'Топ-15 важных признаков: {best_model_name}', fontsize=11)
    plt.xticks(fontsize=9)
    plt.yticks(fontsize=8)
    plt.gca().invert_yaxis()
else:
    plt.text(0.5, 0.5, 'Важность признаков недоступна', ha='center', va='center')

plt.tight_layout()
plt.savefig('model_comparison.png', dpi=300, bbox_inches='tight')
plt.show()

print(f"\n🎯 ЛУЧШАЯ МОДЕЛЬ: {best_model_name}")
print(f"Точность на тестовых данных: {best_model_results['accuracy']:.4f}")
print(f"Средняя точность кросс-валидации: {best_model_results['cv_mean']:.4f}")

print("\nОтчет по классификации для лучшей модели:")
print(classification_report(y_test, best_model_results['y_pred'],
                            target_names=class_names))

print("\nДОПОЛНИТЕЛЬНЫЙ АНАЛИЗ")
print("=" * 50)

print("Анализ переобучения:")
for name in results.keys():
    train_score = results[name]['model'].score(X_train_scaled, y_train)
    test_score = results[name]['accuracy']
    overfitting_gap = train_score - test_score
    print(f"{name}: Train={train_score:.4f}, Test={test_score:.4f}, Gap={overfitting_gap:.4f}")

results_summary = {
    'best_model': best_model_name,
    'best_accuracy': best_model_results['accuracy'],
    'all_results': comparison_df.to_dict()
}

print(f"\nРезультаты сохранены. Лучшая модель: {best_model_name}")