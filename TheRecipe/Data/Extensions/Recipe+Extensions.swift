//
//  Recipe+Extensions.swift
//  The Recipe
//

import CoreData

extension Recipe : TagProvider {
    /// Non-optional ``title`` with an empty string as a default value.
    var wrappedTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    var wrappedSummary: String {
        get { summary ?? "" }
        set { summary = newValue }
    }
    var wrappedSource: String {
        get { source ?? "" }
        set { source = newValue }
    }
    
    var wrappedVideoUrl: String {
        get { videoUrl ?? "" }
        set { videoUrl = newValue }
    }
    var wrappedComment: String {
        get { comment ?? "" }
        set { comment = newValue }
    }
    
    var wrappedMakes: String {
        get { makes ?? "" }
        set { makes = newValue }
    }
    /// Non-optional ``ingredients``  cast to the proper type.
    var wrappedIngredients: Set<RecipeIngredient> {
        get { ingredients as? Set<RecipeIngredient> ?? [] }
        set { ingredients = newValue as NSSet }
    }
    
    /// Non-optional ``cookingSteps``  cast to the proper type.
    var wrappedCookingSteps: Set<CookingStep> {
        get { cookingSteps as? Set<CookingStep> ?? [] }
        set { cookingSteps = newValue as NSSet }
    }
    
    /// Non-optional ``images``  cast to the proper type.
    var wrappedImages: Set<RecipeImage> {
        get { images as? Set<RecipeImage> ?? [] }
        set { images = newValue as NSSet }
    }
    
    /// Non-optional ``tags``  cast to the proper type.
    var wrappedTags: Set<Tag> {
        get { tags as? Set<Tag> ?? [] }
        set { tags = newValue as NSSet }
    }
    
    /// Non-optional ``parts``  cast to the proper type.
    var wrappedParts: Set<Recipe> {
        get { parts as? Set<Recipe> ?? [] }
        set { parts = newValue as NSSet }
    }
    var wrappedDinnerMenuItem: Set<DinnerMenuItem> {
        get { dinnerMenuItems as? Set<DinnerMenuItem> ?? [] }
        set { dinnerMenuItems = newValue as NSSet }
    }
    var isEmpty : Bool {
        return wrappedTitle.isEmpty && wrappedCookingSteps.count == 0 && wrappedIngredients.count == 0
    }
    var isInProgress : Bool {
        return wrappedTitle.isEmpty || wrappedCookingSteps.count == 0 || wrappedIngredients.count == 0
    }
    // MARK: - Relationship Management
    
    /// Adds a new ingredient to the recipe.
    ///
    /// Creates ``RecipeIngredient`` relationship linking the ingredient to the recipe.
    /// Ingredient order is automatically increased and the ingredient is automatically added to the recipe.
    ///
    /// If the `amount` is specified - it is prefilled into the ``RecipeIngredient``.
    ///
    /// - Parameter ingredient: Ingredient to add.
    /// - Parameter value:      Tuple with amount and unit.
    ///
    /// - Returns: Newly created ``RecipeIngredient``.
    @discardableResult
    func addIngredient(_ ingredient: Ingredient? = nil, amount: Double = 0, unit: Unit? = nil) -> RecipeIngredient {
        let relation: RecipeIngredient
        relation = .init(context: managedObjectContext!) // FIXME: Need to double-check, but this is never supposed to fail.
        relation.ingredient = ingredient
        relation.wrappedOrder = wrappedIngredients.count
        relation.amount = amount
        if let unit = unit {
            relation.wrappedUnit = unit
        }
        relation.recipe = self
        return relation
    }
    
    
    /// Creates new ``CookingStep`` in the next ordering position.
    ///
    /// Newly created ``CookingStep`` is automatically ordered and added to the recipe.
    ///
    /// - Returns: Newly created step.
    func addCookingStep() -> CookingStep {
        let step = CookingStep(context: managedObjectContext!) // FIXME: Need to double-check, but this is never supposed to fail.
        step.wrappedOrder = wrappedCookingSteps.count
        step.recipe = self
        return step
    }
    
    /// Creates new ``RecipeImage`` from the given ``KitImage``.
    ///
    /// Newly created ``RecipeImage`` is automatically ordered and added to the recipe.

    /// - Parameter kitImage: Image to add.
    ///
    /// - Returns: Newly created ``RecipeImage``.
    func addImage(_ kitImage: KitImage? = nil) -> RecipeImage {
        let img = RecipeImage(context: managedObjectContext!)
        img.image = kitImage?.pngData()
        img.recipe = self
        return img
    }
    
    func addImage(url: String, licenseUrl: String?) -> RecipeImage? {
        if let _ = URL(string: url) {
            let img = RecipeImage(context: managedObjectContext!)
            img.imageUrl = url
            img.licenseUrl = licenseUrl
            img.recipe = self
            return img
        }
        return nil
    }
    
    func copyIt() -> Recipe {
        let copy = Recipe(context: managedObjectContext!)
        copy.wrappedIngredients = self.wrappedIngredients
        copy.wrappedCookingSteps = self.wrappedCookingSteps
        copy.wrappedSummary = self.wrappedSummary
        copy.wrappedImages = self.wrappedImages
        copy.wrappedSource = self.wrappedSource
        copy.wrappedComment = self.wrappedComment
        copy.wrappedTags = self.wrappedTags
        copy.wrappedVideoUrl = self.wrappedVideoUrl
        copy.wrappedTitle = self.wrappedTitle + " copy"

        
        return copy
    }
    // MARK: - Predicates
    
    /// Builds a conditional predicate based on the given  tag or search query.
    ///
    /// `tagSelection` and `query` are mutually exclusive.
    ///
    /// - If `query` is not empty, it will take precedence over the `tagSelection` and the resulting
    ///     predicate will be built to match various parts of the recipe, including title, summary, and tags.
    ///     The search is performed globally.
    /// - When `query` is empty, the predicate will match all records in case `tagSelection` equals to ``Selection/allrecipes``,
    ///     or `nil`. Otherwise it will match only the recipes tagged with the given tag.
    ///
    /// - Parameter tagSelection: Selected tag.
    /// - Parameter searchQuery:  Search query.
    ///
    /// - Returns: Predicate to fetch the result based on selection.
    static func predicate(forTaggedWith tagSelection: Selection<Tag>?, orMatching searchQuery: String = "") -> NSPredicate {
        guard !searchQuery.isEmpty else {
            if case let .one(tag) = tagSelection {
                return .init(format: "%K contains[cd] %@", #keyPath(Recipe.tags), tag)
            }
            return .init(value: true)
        }
        return .init(format: "%K contains[cd] %@ OR %K contains[cd] %@ OR ANY %K.name contains[cd] %@",
                     #keyPath(Recipe.title), searchQuery,
                     #keyPath(Recipe.summary), searchQuery,
                     #keyPath(Recipe.tags), searchQuery
        )
    }

    // MARK: - Other Methods

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
        setPrimitiveValue(NSLocalizedString("", comment: "New recipe default title"), forKey: #keyPath(title))
        setPrimitiveValue(Date(), forKey: #keyPath(lastModified))
    }
}
