self: super: {
  Firefox = super.callPackage ./firefox { };
  Rectangle = super.callPackage ./rectangle { };
}