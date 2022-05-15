//
//  CategoryEditorViewController.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 1.05.22.
//

import UIKit

protocol CategoryEditorViewControllerDelegate: AnyObject {
    func categoryEditor(vc: CategoryEditorViewController, didCreateNew category: CategoryObject)
    func categoryEditor(vc: CategoryEditorViewController, didEdit category: CategoryObject, with new: CategoryObject)
}

class CategoryEditorViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var paymentTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var collectionView: UICollectionView?
    var currentCategory: CategoryObject?
    var paymentType: PaymentType?
    var currentImageIndex: Int?
    
    
    weak var delegate: CategoryEditorViewControllerDelegate?
    
    // I'll fill it with more elements of course. a little bit later)
    let availibleImageNames: [String] = ["ellipsis","pawprint","book","cross","cart","takeoutbag.and.cup.and.straw","globe.europe.africa","tag","house","gift","1.square","2.square","app.gift","pencil","scribble","lasso","trash","folder","paperplane","archivebox","doc","doc.text","person","person.3","command","power","globe","sun.max","thermometer","flame","umbrella","keyboard","exclamationmark.triangle","play","music.note","music.mic","magnifyingglass","mic","circle","square","triangle","suit.heart","suit.spade","heart","star","flag","bell","bolt","eye","eyeglasses","icloud","camera","message","phone","video","envelope","gear","scissors","bag","creditcard","wand.and.stars","nosign","tuningfork","paintbrush","bandage","wrench","hammer","eyedropper","briefcase","lock","lock.shield","wifi","pin","mappin","map","desktopcomputer","headphones","hifispeaker","tv","guitars","airplane","car","hare","tortoise","ant","film","sportscourt","shield","cube","scope","helm","clock","alarm","stopwatch","gamecontroller", "logo.playstation", "logo.xbox","ear","hand.raised","chart.bar","waveform.path.ecg","waveform.path","waveform","app.gift","studentdesk","hourglass","burn","battery.100","battery.25","battery.0","lightbulb","questionmark","exclamationmark","plus","minus","checkmark","terminal","books.vertical","book.closed","greetingcard","newspaper","graduationcap","ticket","network","cursorarrow","drop","infinity","megaphone","speaker.wave.3","loupe","target","mustache","mail.stack","gearshape.2","gearshape","giftcard","die.face.5","pianokeys.inverse","paintbrush.pointed","wrench.and.screwdriver","stethoscope","case","puzzlepiece","building.columns","signpost.left","building","key","pc","laptopcomputer","candybarphone","radio","bolt.car","bus", "bicycle", "lungs", "pills", "ladybug", "leaf", "face.smiling", "crown", "comb", "checkerboard.rectangle", "photo.on.rectangle.angled", "shippingbox", "paintpalette", "figure.walk", "waveform.path.ecg.rectangle", "simcard", "sdcard", "banknote", "binoculars", "minus.plus.batteryblock", "bed.double", "menucard", "cup.and.saucer", "takeoutbag.and.cup.and.straw", "fork.knife", "magazine", "person.3.sequence", "person.crop.artframe", "photo.artframe", "peacesign", "globe.americas", "globe.europe.africa", "globe.asia.australia", "snowflake", "flag.and.flag.filled.crossed", "tshirt", "facemask", "brain.head.profile", "brain", "screwdriver", "suitcase", "theatermasks", "ferry", "scooter", "fuelpump", "allergens", "testtube.2", "ivfluid.bag", "cross.vial", "figure.roll", "hourglass.bottomhalf.filled"]
    
    let cellId = "collectionViewCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performInitialConfiguration()
    }
    
    private func performInitialConfiguration() {
        hideKeyboardWhenTappedAround()
        setupCollectionView()
        checkCurrentAccount()
        
    }
    
    private func setupCollectionView() {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.itemSize = CGSize(width: (containerView.frame.width / 5),height: (containerView.frame.width / 5))
        
        let collectionView = UICollectionView(frame: containerView.frame, collectionViewLayout: collectionViewFlowLayout)
        collectionView.layer.cornerRadius = 15

        self.collectionView = collectionView
        containerView.addSubview(collectionView)
        collectionView.fillSuperview()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        
        collectionView.register(UINib(nibName: "CategoryImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
    }
    
    private func checkCurrentAccount() {
        guard let currentCategory = currentCategory else { return }
        if currentCategory.type == .expense {
            paymentTypeSegmentedControl.selectedSegmentIndex = 0
            paymentType = .expense
        } else {
            paymentTypeSegmentedControl.selectedSegmentIndex = 1
            paymentType = .income
        }
        nameTextField.text = currentCategory.name
        iconImageView.image = UIImage(systemName: currentCategory.iconName)
        currentImageIndex = availibleImageNames.firstIndex(where: {
            $0 == currentCategory.iconName
        })
        
    }
    
    @IBAction func paymentTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            paymentType = .expense
        } else {
            paymentType = .income
        }
    }
    
    @IBAction func cancelButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonDidTap(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        guard name != "" else { return }
        let type = paymentType ?? .expense
        let iconName = availibleImageNames[currentImageIndex ?? 0]
        
        let newCategory = CategoryObject(name: name, iconName: iconName, type: type)
                
        if currentCategory == nil {
            delegate?.categoryEditor(vc: self, didCreateNew: newCategory)
        } else if currentCategory != nil && currentCategory == newCategory {
            return
        } else if currentCategory != nil && currentCategory != newCategory {
            delegate?.categoryEditor(vc: self, didEdit: currentCategory!, with: newCategory)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}


extension CategoryEditorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        availibleImageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? CategoryImageCollectionViewCell
        
        let imageName = availibleImageNames[indexPath.row]
        let image = UIImage(systemName: imageName)
        cell?.iconImageView.image = image
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        iconImageView.image = UIImage(systemName: availibleImageNames[indexPath.row])
        currentImageIndex = indexPath.row
    }
    
}

extension CategoryEditorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = containerView.frame.width / 7
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
