import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import DeactivatedPopup from './deactivatedPopup';

describe('<DeactivatedPopup />', () => {
  test('it should mount', () => {
    render(<DeactivatedPopup />);
    
    const DeactivatedPopup = screen.getByTestId('DeactivatedPopup');

    expect(DeactivatedPopup).toBeInTheDocument();
  });
});