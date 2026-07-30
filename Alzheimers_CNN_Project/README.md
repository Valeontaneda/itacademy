🧠 AD-MRI-CNN
Classification of Alzheimer's disease from brain MRI scans, comparing a CNN trained from scratch against transfer learning (EfficientNetB0), with strictly patient-level evaluation.

🎯 Description
AD-MRI-CNN is a Deep Learning project applied to neuroimaging, aimed at evaluating whether Alzheimer's disease can be detected from axial slices of structural brain MRI.

The project combines two independent cohorts from the Open Access Series of Imaging Studies (OASIS) — OASIS-1 (already preprocessed data) and OASIS-2 (raw scanner data) — and compares several modeling approaches, from a naive baseline to convolutional neural networks with and without transfer learning.

The methodological backbone of the project is splitting the data at the patient level (not the image level), to avoid the data leakage that artificially inflates performance in much of the published literature on these same datasets.

🚀 Project Objectives
* Build a preprocessing pipeline that brings OASIS-2 (raw data) into the same image domain as OASIS-1 (skull stripping, registration to a common template).
* Combine both cohorts into a single 318-patient dataset, maximizing the sample size available for training.
* Split the data at the patient level, stratified by label and source, to avoid data leakage between training, validation, and test sets.
* Compare a baseline, a CNN trained from scratch, a CNN with augmentation + early stopping, and an EfficientNetB0 transfer learning model.
* Evaluate performance at the patient level (soft voting across slices) and analyze it against clinical severity (CDR).

🧠 Project Architecture
```
OASIS-1 (preprocessed) + OASIS-2 (raw)
                │
                ▼
      Image preprocessing
 (skull stripping, registration,
       slice extraction)
                │
                ▼
   Patient-level data split
   (train / val / test, 70/15/15)
                │
                ▼
       Model training
 (baseline → CNN → augmented CNN
      → transfer learning)
                │
                ▼
  Patient-level evaluation
 (soft voting + CDR-stratified analysis)
```

📷 Results in Action
The project generates visualizations that make it easier to interpret each model's performance and compare them.

**Model comparison on the test set**
`visualizations/model_comparison_test.png`

**Training curves (accuracy / loss)**
`visualizations/augmented_cnn_training_curves.png`

**Confusion matrices by model**
`visualizations/test_confusion_matrices.png`

**Performance stratified by CDR score**
`visualizations/performance_by_cdr.png`

🧩 Models Included
| Model | Description |
|---|---|
| 🎯 Baseline | Majority-class `DummyClassifier`; sets the accuracy floor to beat |
| 🧱 CNN from scratch | 3-block convolutional network trained only on this data, no regularization |
| 🔁 Augmented CNN | Same architecture + light rotation/translation + early stopping on `val_accuracy` |
| 🧠 Transfer Learning | EfficientNetB0 pretrained on ImageNet, two-phase fine-tuning |

📊 Metrics Computed
| Metric | Description |
|---|---|
| ✅ Accuracy | Proportion of patients correctly classified |
| 🎯 Precision | Proportion of positive predictions that are correct |
| 🔎 Recall (Sensitivity) | Proportion of actual positive cases detected |
| ⚖️ F1 | Harmonic mean of precision and recall |

📈 Dataset
Combined cohort built specifically for this project from OASIS-1 and OASIS-2, restricted to patients aged 60 and older.

* 🗂️ **318 patients** (198 from OASIS-1, 120 from OASIS-2)
* 🖼️ **3,180 images** (10 axial slices per patient)
* 🏷️ Binary labels: `non_demented` (CDR = 0) vs. `alzheimer` (CDR > 0)
* 🔀 Patient-level split, stratified by label and source:

| Split | Non-demented | Alzheimer's | Total |
|---|---|---|---|
| Training | 116 | 106 | 222 |
| Validation | 26 | 22 | 48 |
| Test | 25 | 23 | 48 |

🔬 Methodological Validation
The project places special emphasis on leakage-free evaluation:

* **Patient-level** split, not image-level (a given patient's 10 slices never end up split across partitions).
* **Soft voting**: each patient's prediction averages the probabilities across their 10 slices.
* Data augmentation restricted to transformations that preserve the clinical signal (rotation/translation; no zoom).
* Performance analysis stratified by **CDR** score to evaluate results by clinical severity.

🛠️ Technologies Used
* Python
* TensorFlow / Keras
* Scikit-learn
* ANTsPy / ANTsPyNet
* NiBabel
* NumPy / Pandas
* Matplotlib / Seaborn
* Google Colab
* Kaggle

💡 Key Features
✔ Preprocessing pipeline for raw MRI data (OASIS-2).
✔ Patient-level data split, free of data leakage.
✔ Training and comparison of 4 models (baseline, CNN, augmented CNN, transfer learning).
✔ Patient-level evaluation via soft voting.
✔ Performance analysis stratified by clinical severity (CDR).
✔ Automatic generation of comparison tables and visualizations.

📄 Documentation
Full technical and methodological documentation is spread across the project notebooks and the final report

👩‍💻 Author
**Valeria Ontaneda**

Tutor: Yunier Córdova Cobas

2026
