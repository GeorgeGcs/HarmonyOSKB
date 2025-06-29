# 【HarmonyOS 5】Detailed Explanation of Data Security in HarmonyOS Applications  

\## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Preface  
What concerns you most when using smartphones or smartwatches? Definitely the fear of privacy data leaks! Today, let's explore how HarmonyOS builds a solid "security shield" to protect our information from all angles.  

#### 1、System-Level "Golden Bell Shield"  
HarmonyOS acts as a "security steward" for your device, strengthening protection from the system core. Features like **integrity protection** prevent system file tampering, **vulnerability exploitation prevention** blocks hacker entry points, and a **secure trusted environment** safeguards critical operations like payments and logins. This creates a "security barrier" for your daily activities.  

#### 2、App Market's "Flaming Eye"  
App markets often host malicious software, but HarmonyOS's DevEco Studio and tools serve as vigilant administrators. Through strict **end-to-end security checks**, they filter out apps that steal information or display intrusive ads, ensuring downloaded apps are trustworthy.  

#### 3、Data Protection "Safe"  
HarmonyOS provides an intelligent safe for user data:  

- **Data Classification Management**:  
  Data is graded by sensitivity: ID numbers are "high-sensitive," while nicknames are "low-sensitive." Sensitive data must follow strict flow rules.  

- **Layered File Encryption**:  
  Files are stored in encrypted directories based on importance. Ordinary files go into "standard lock rooms" (EL2), requiring device unlock; critical files use "super lock rooms" (EL4), auto-locking after 10 seconds of inactivity.  

- **Key "Personal Butler"**:  
  The HarmonyOS Universal Key Store (HUKS) manages encryption keys, acting as a 24/7 bodyguard for your data.  


### 二、"Security Pass" for Devices and Data  

#### 1、Device Security Levels  
HarmonyOS classifies devices into 5 security levels (SL1-SL5):  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_01d382df.png 'image.png')  

Devices are rated based on capabilities like TEE (Trusted Execution Environment) and secure storage chips:  

| Level | Security Capability | Typical Devices       |  
|-------|---------------------|-----------------------|  
| SL1   | Low Security        | Smart wearables       |  
| SL5   | High Security       | Smartphones, tablets  |  

Cross-device data synchronization follows the rule: **data security label ≤ target device security level**. For example, SL1 devices can only sync S1-level data.  

#### 2、Data "Sensitivity Register"  
Data is divided into four levels (S1-S4):  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_16838098.png 'image.png')  

- **S4 (Ultra-Sensitive)**: Political views, biometric data, etc.  
- **S1 (General)**: Gender, nationality, etc.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_33e662aa.png 'image.png')  

Developers can apply appropriate encryption based on data sensitivity, similar to using different locks for items of varying value.  


### 三、Demo Example: Encryption Processing for Medical Data  
Many use smartphones to record medical data, which falls under high-sensitivity information. Here's how HarmonyOS protects it:  

1. **Dual Encryption "Double Insurance"**: Data is encrypted twice and stored in a classified encrypted directory, like wearing two layers of "bulletproof vests."  
2. **Rigorous Development Process**:  
   - **Data Entry**: Information is packaged, encrypted by HUKS, and stored in an encrypted file repository.  
   - **Data Viewing**: Encrypted files are retrieved and decrypted using keys.  

The following code snippet demonstrates encryption, essentially instructing the device to "hide data using AES algorithm":  

```typescript  
// Generate encryption key  
function GetAesGenerateProperties() {  
  return [  
    { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },  
    { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128 },  
    // Instruct the device that this key is for encryption and decryption  
    { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT }  
  ];  
}  
```  

#### Health Data Storage Example  
HarmonyOS ensures high-sensitivity data security through a **dual encryption strategy**:  

##### 1、Scenario Design  
- **Data Classification**: Medical data is S3-level high-risk, requiring secondary encryption.  
- **Page Design**: Includes medical record list, data entry, and detail pages.  

##### 2、Code Implementation  

###### Data Encryption Process  
```typescript  
// 1. Generate AES algorithm key  
function GetAesGenerateProperties() {  
  return [  
    { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },  
    { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128 },  
    { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT }  
  ];  
}  

// 2. Configure encryption parameters  
function GetAesEncryptProperties() {  
  return [  
    // Configure algorithm, key size, padding mode, etc.  
  ];  
}  

// 3. Execute encryption  
async function EncryptData() {  
  const properties = GetAesEncryptProperties();  
  const options = { properties, inData: StringToUint8Array(plainText) };  
  await huks.initSession(aesKeyAlias, options)  
    .then((data) => { /* Handle session */ })  
    .catch((error) => { /* Error handling */ });  
  await huks.finishSession(handle, options)  
    .then((data) => { /* Successful encryption handling */ })  
    .catch((error) => { /* Encryption failure handling */ });  
}  
```  

###### Data Decryption Process  
The decryption process is the reverse of encryption, requiring reading the classified encrypted file and using the same algorithm and key:  

```typescript  
function GetAesDecryptProperties() {  
  // Configure decryption parameters (consistent with encryption, modify purpose to decryption)  
}  

async function DecryptData() {  
  const properties = GetAesDecryptProperties();  
  const options = { properties, inData: cipherData };  
  // Execute decryption operation  
}  
```  


### Summary: HarmonyOS Security "Trilogy"  
1. **Detailed Data Classification**: Differentiate between important and general data.  
2. **Flexible Encryption Strategies**: Use strong encryption for critical data and moderate encryption for general data to balance security and user experience.  
3. **Continuous Upgrades**: As hacking techniques evolve, HarmonyOS continuously updates its security technologies to protect your data.  
